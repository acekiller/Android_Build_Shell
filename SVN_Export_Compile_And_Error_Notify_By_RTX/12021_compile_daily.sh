#!/bin/bash
#
#	Description:
#		Used to export the code and compile.
#
#	History:
#		gpeak,2012/01/07 for QE
#		long.luo, 2012/08/12, modified.
#

#--------------------------------------------------------------------------------------------
source ~/.profile
#LANG=zh_CN.UTF-8
#export LANG

DATE=`date +%F-%H`
BUILD_DATE=`date +%y%m%d`

#project_name
PROJCT=12021

#baseline URL
BASE_URL=http://192.168.3.240/svn/oppo_swdp/ics2/development

#download source code here
SOURCE_PATH=/work/12021_Tst/SRC

#where is the output 
TARGET_PATH=/work/12021_Tst/OUT

#source code root dir
PRJ=development

#project name
PRJ_NAME=oppo77_12021

#compile output dir
OUT_PATH=out/target/product/${PRJ_NAME}

#save the version of last build
#first time you should touch the file once
LOG_PATH=/work/12021_Tst/script/log/12021_info.log

SVN_COMMIT_HISTORY=/work/12021_Tst/script/svn_commit_history.map
RTX_ID_MAP=/work/12021_Tst/script/svn_2_rtx_id.map


#where is this script
SH=/work/12021_Tst/script

#software version
SOFT_VERSION=2.01
OTA_VERSION=001

#output to file server
#first you should mount the file server to local dir
#for example 
#mount -t cifs -o username=80054374,password=gao-888,iocharset=utf8,uid=0,gid=0,rwx  //172.16.103.17/M5_SW_release   /mnt/17server
CHANGAN_PATH=/mnt/32server/12021\(MT6577\)/每日构建版本
SHENZHEN_PATH=/mnt/186server/12021/daily_build

#database and database_AP
DATA_PATH=mediatek/custom/out/${PRJ_NAME}/modem/BPLGUI*
APDA_PATH=mediatek/source/cgen/APDB_MT6577_S01_MAIN2.1_W10.24

BUILD_NUM=R817_11_${SOFT_VERSION}_${BUILD_DATE}
OTA_NUM=R817_11_${SOFT_VERSION}_${OTA_VERSION}_${BUILD_DATE}

DEVINFO=oppo/app/public/Settings/src/com/android/settings/DeviceInfoSettings.java
CHKINFO=oppo/app/service/EngineerMode/src/com/oppo/engineermode/CheckSoftwareInfo.java
PROCONF=build/target/product/${PRJ_NAME}.mk
MTKCONF=mediatek/config/common/ProjectConfig.mk

#
#RTX_SDK_SERVER="172.16.101.201:8012"
RTX_SDK_SERVER="192.168.1.153:8012"
#RTX_NOTIFY_RECEIVER="test"
RTX_NOTIFY_RECEIVER="1645"


#
SVN_COMMITTER_ID_ARRAY=(`cat ${SVN_COMMIT_HISTORY}`)
RTX_ID_MAP_ARRAY=(`cat ${RTX_ID_MAP}`)

SVN_COMMITTER_ID_ARRAY_LENGTH=${#SVN_COMMITTER_ID_ARRAY[@]}
RTX_ID_MAP_ARRAY_LENGTH=${#RTX_ID_MAP_ARRAY[@]}
#

#--------------------------------------------------------------------------------------------
check_exit() {
    EXIT=$?    
    echo EXIT=$EXIT
}

common_build_need(){
	SVN_VERSION_OLD=`cat $LOG_PATH`	
	echo SVN_VERSION_OLD=$SVN_VERSION_OLD	

	SVN_VERSION_NOW=`svn info ${BASE_URL} | awk '/Last.Changed.Rev:/{print $4}'`
	echo SVN_VERSION_NOW=$SVN_VERSION_NOW	
	
	#
	SVN_VERSION_NOW=3515
	echo SVN_VERSION_NOW=$SVN_VERSION_NOW	
 
	if [ $SVN_VERSION_NOW = $SVN_VERSION_OLD ]; then
		echo SVN_VERSION_NOW = SVN_VERSION_OLD Not Need Rebuild
		exit 0
	fi
}

fn_send_rtx_notify()
{
	echo "	fn_send_rtx_notify...: ${1}"
	
	echo "cd ${SH}"
	cd "${SH}"

	echo "<<< RTX_NOTIFY=${RTX_NOTIFY}"
	RTX_NOTIFY=${1}
	echo ">>> RTX_NOTIFY=${RTX_NOTIFY}"
	echo "./rtx_send_msg.py -s ${RTX_SDK_SERVER} -u ${RTX_NOTIFY_RECEIVER} -m ${RTX_NOTIFY}"
	
	./rtx_send_msg.py -s ${RTX_SDK_SERVER} -u ${RTX_NOTIFY_RECEIVER} -m ${RTX_NOTIFY}
	check_exit
}

fn_get_svn_committer_id()
{
	echo "	fn_get_svn_committer_id..."
	
	SVN_VERSION_TEMP=${SVN_VERSION_OLD}
	echo "SVN_VERSION_TEMP=${SVN_VERSION_TEMP}"
	
	while [ ${SVN_VERSION_TEMP} -le ${SVN_VERSION_NOW} ]
	do
		SVN_COMMITTER=`svn info ${BASE_URL} -r ${SVN_VERSION_TEMP} | awk '/Last.Changed.Author:/{print $4}'` 
		echo "${SVN_VERSION_TEMP} ${SVN_COMMITTER} " >> ${SVN_COMMIT_HISTORY}
		SVN_VERSION_TEMP=`expr ${SVN_VERSION_TEMP} + 1`
		EXIT=$?
		check_exit
	done
}

fn_get_rtx_id_by_svn_id()
{
	echo "	fn_get_rtx_id_by_svn_id..."
	
	echo "SVN_COMMITTER_ID_ARRAY_LENGTH=${SVN_COMMITTER_ID_ARRAY_LENGTH}"
	echo "RTX_ID_MAP_ARRAY_LENGTH=${RTX_ID_MAP_ARRAY_LENGTH}"
	
	for ((i=0; i<${SVN_COMMITTER_ID_ARRAY_LENGTH}; i++))
	do
		j=`expr ${i} + 1`
		
		echo "i=${i}, j=${j}"
		SVN_COMMITTER_ID=${SVN_COMMITTER_ID_ARRAY[${j}]%/*}
		echo "SVN_COMMITTER_ID=${SVN_COMMITTER_ID}"
		
		for ((x=0; x<${RTX_ID_MAP_ARRAY_LENGTH}; x++))
		do
			y=`expr ${x} + 1`
			echo "x=${x}, y=${y}"
			RTX_NAME=${RTX_ID_MAP_ARRAY[${x}]%' '*}
			
			echo "RTX_NAME=${RTX_NAME}"
			echo "SVN_COMMITTER_ID=${SVN_COMMITTER_ID}"
			
			if [[ "${RTX_NAME}" == "${SVN_COMMITTER_ID}" ]]; then
				echo "${RTX_NAME} == ${SVN_COMMITTER_ID}"
				RTX_ID=${RTX_ID_MAP_ARRAY[${y}]%' '*}
				echo "RTX_ID=${RTX_ID}"
				
				RTX_NOTIFY_RECEIVER="${RTX_NOTIFY_RECEIVER},${RTX_ID}"
				echo "RTX_NOTIFY_RECEIVER=${RTX_NOTIFY_RECEIVER}"
			fi
			
			x=`expr ${x} + 1`
		done
		      
		i=`expr ${i} + 1` 
	done
	
	echo "RTX_NOTIFY_RECEIVER=${RTX_NOTIFY_RECEIVER}"
}

fn_clear_svn_commit_history()
{
	echo "	fn_clear_svn_commit_history..."	
	rm -f ${SVN_COMMIT_HISTORY}
}

common_export_source(){
	echo "rm $SOURCE_PATH/$PRJ"	
	rm -rf $SOURCE_PATH/$PRJ
	
	echo "export source from SVN..."
	cd $SOURCE_PATH
	echo $PWD

	local START_TIME=$(date +%s)
	date
	svn export -r $SVN_VERSION_NOW ${BASE_URL} -q
	date
	local END_TIME=$(date +%s)
	local DIFF=$((${END_TIME} - ${START_TIME}))
	echo "**********SVN export code takes `expr ${DIFF} / 60` minutes `expr ${DIFF} % 60` seconds"
	
	#
	fn_send_rtx_notify "${PROJCT} export SVN${SVN_VERSION_NOW} Code OK!"
	
	echo "mkdir TARGET PATH"
	TARGET_PATH=${TARGET_PATH}/${DATE}_SVN${SVN_VERSION_NOW}
	mkdir ${TARGET_PATH}
	
	echo "save svn info"
	echo $SVN_VERSION_NOW > $LOG_PATH
}


modify_version(){	
	cd $SOURCE_PATH/$PRJ
	
	echo "Modify Setting info..."
	chmod 777 ${DEVINFO}
	awk '{gsub(/3.0.35.7/,"3.0.35.7-'$SVN_VERSION_NOW'");print}' ${DEVINFO} > DeviceInfoSettings_temp.java
	awk '{gsub(/11071/,"'$BUILD_NUM'");print}' DeviceInfoSettings_temp.java > DeviceInfoSettings_temp1.java
	mv DeviceInfoSettings_temp1.java ${DEVINFO}
	rm DeviceInfoSettings_temp.java

	echo "Modify Engineer info..."
	chmod 777 ${CHKINFO}
	awk '{gsub(/3.0.35.7/,"3.0.35.7-'$SVN_VERSION_NOW'");print}' ${CHKINFO} > CheckSoftwareInfo_temp.java
	mv CheckSoftwareInfo_temp.java ${CHKINFO}
	
	chmod 777 ${MTKCONF}
	awk '{gsub(/ALPS.ICS2.6577.SP.V1/,"'$BUILD_NUM'");print}' ${MTKCONF} > ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${MTKCONF}
}

modify_version_daily(){
	modify_version
	
	cd $SOURCE_PATH/$PRJ
	
	echo "Modify ProjectConfig info..."
	chmod 777 ${PROCONF}
	awk '{gsub(/OPPO.BUILD.VERNO....R817/,"OPPO_BUILD_VERNO := '${BUILD_NUM}'_SVN'$SVN_VERSION_NOW'");print}' ${PROCONF}> ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PROCONF}
	awk '{gsub(/export.BUILD.VERSION.OTA.R817/,"export BUILD_VERSION_OTA='${OTA_NUM}'");print}' ${PROCONF}> ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PROCONF}
}

compile_eng_new(){
	cd $SOURCE_PATH/$PRJ
	
	echo "compile eng code..."
	# Modified begin by long.luo, for add measuring the time.
	local START_TIME=$(date +%s)
	
	./makeMtk ${PRJ_NAME} new
	EXIT=$?
	
	local END_TIME=$(date +%s)
	local DIFF=$((${END_TIME} - ${START_TIME}))
	echo "**********Build source takes `expr ${DIFF} / 60` minutes `expr ${DIFF} % 60` seconds"
	# Modified end.
	
	#
	fn_send_rtx_notify "${PROJCT} ${DATE}_SVN${SVN_VERSION_NOW} Compile OKay!"
	
	if [ $EXIT != 0 ];then
		echo "Compile Failed!"
		
		fn_send_rtx_notify "${PROJCT} ${DATE}_SVN${SVN_VERSION_NOW} Compile Failed!"
		
		mv ${TARGET_PATH} ${TARGET_PATH}_ERR
		cp ${OUT_PATH}_* ${TARGET_PATH}_ERR
		copy_error_to_shenzhen
	  exit 0
	fi
}

package_eng_new(){
	cd $SOURCE_PATH/$PRJ
	
	echo "package version..."
	mkdir out_img
	cp ${OUT_PATH}/* out_img/
	cp ${DATA_PATH} out_img/${BUILD_NUM}_database
	cp ${APDA_PATH} out_img/${BUILD_NUM}_database_AP
	mv out_img ${PROJCT}_SVN${SVN_VERSION_NOW}_${BUILD_DATE}
	tar chzf ${BUILD_NUM}_SVN${SVN_VERSION_NOW}.tar.gz ${PROJCT}_SVN${SVN_VERSION_NOW}_${BUILD_DATE}
	check_exit
	
	echo "copy to TARGET_PATH..."
	mv ${BUILD_NUM}_SVN${SVN_VERSION_NOW}.tar.gz ${TARGET_PATH}/
}

package_eng_new_daily(){
	package_eng_new

	cd $SOURCE_PATH/$PRJ

	echo "package and copy out dir..."
	tar chzf out_SVN${SVN_VERSION_NOW}.tgz out/
	mv out_SVN${SVN_VERSION_NOW}.tgz ${TARGET_PATH}/
	
	echo "copy svn log..."
	touch log.txt
	svn log -r ${SVN_VERSION_OLD}:${SVN_VERSION_NOW} ${BASE_URL} > log.txt
	cp log.txt ${TARGET_PATH}/
}


copy_error_to_shenzhen(){
	echo "copy error to shenzhen"
	cp -r ${TARGET_PATH}_ERR ${SHENZHEN_PATH}/
}
copy_to_shenzhen(){
	echo "copy to shenzhen"
	date
	cp -r $TARGET_PATH ${SHENZHEN_PATH}/
	date
}
rm_local_version(){
	rm -r $TARGET_PATH
	date
}

#--------------------------------------------------------------------------------------------
echo -e "\n================================ Start ================================\n"
echo Now time=`date`
ALL_START_TIME=$(date +%s)

common_build_need
fn_clear_svn_commit_history
fn_get_svn_committer_id
fn_get_rtx_id_by_svn_id
#common_export_source
#modify_version_daily
#compile_eng_new
#package_eng_new_daily
#copy_to_shenzhen
#rm_local_version

ALL_END_TIME=$(date +%s)
ALL_DIFF=$((${ALL_END_TIME} - ${ALL_START_TIME}))
echo "**********All takes `expr ${ALL_DIFF} / 60` minutes `expr ${ALL_DIFF} % 60` seconds"
echo -e "\n================================ End ================================\n"
#--------------------------------------------------------------------------------------------
