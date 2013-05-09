#!/bin/bash
#
#  File:
#		android_prj_usr_build.sh
#
#	Description:
#		Used to export the code and compile.
#
#	History:
#		long.luo, 2013/03/25, modified.
#

#--------------------------------------------------------------------------------------------
#source ~/.profile
#LANG=zh_CN.UTF-8
#export LANG

DATE=`date +%F-%H`
BUILD_DATE=`date +%y%m%d`

#download source code here
#SOURCE_PATH=/work/12083/SRC
SOURCE_PATH=`pwd`

#where is the output 
#TARGET_PATH=/work/12083/OUT
TARGET_PATH=`pwd`

#where is this script
#SH=/work/12083/script

#software version
BRANCH_NUM=2.01
OTA_SERIAL=001

#output to file server
#first you should mount the file server to local dir
#for example 
#mount -t cifs -o username=8005xxxx,password=xxxxxx,iocharset=utf8,uid=0,gid=0,rwx  //172.16.103.17/M5_SW_release   /mnt/17server
CHANGAN_PATH=/mnt/136server/12083/User_Build_Everyday

#database and database_AP
DATA_PATH=mediatek/custom/out/${PRJ_NAME}/modem/BPLGUI*
APDA_PATH=mediatek/cgen/APDB_MT6589_S01_MAIN2.1_W10.24

SOFT_VERSION=R809T_11_${BUILD_DATE}
BUILD_NUM_MTK=R809T_11_${BRANCH_NUM}_${BUILD_DATE}
OTA_VERSION=R809T_11.${BRANCH_NUM}_${OTA_SERIAL}_${BUILD_DATE}


#--------------------------------------------------------------------------------------------
check_exit() 
{
    EXIT=$?    
    echo EXIT=$EXIT
}


prj_init()
{
	#project_name
	PROJECT=${ARG_PROJECT}

	#SVN baseline URL
	BASE_URL=http://192.168.3.193/svn/mt6589/development_mp

	#source code root dir
	PRJ_PATH=development_mp

	#project name
	PRJ_NAME=OPPO89T_${PROJECT}

	#compile output dir
	OUT_PATH=out/target/product/${PRJ_NAME}
}


export_source_code()
{
	SVN_VERSION_NOW=${SW_SVN_REVISION}
	echo SVN_VERSION_NOW=$SVN_VERSION_NOW		
	
	echo "export source from SVN..."
	cd $SOURCE_PATH
	echo $PWD
	date
	svn export -r ${SVN_VERSION_NOW} ${BASE_URL} -q
	date
	echo "mkdir TARGET PATH"
	TARGET_PATH=${TARGET_PATH}/${DATE}_SVN${SVN_VERSION_NOW}
	mkdir ${TARGET_PATH}
	
	mv ${PRJ_PATH} ${PRJ_PATH}_usr_${SVN_VERSION_NOW}
	PRJ_PATH=${PRJ_PATH}_usr_${SVN_VERSION_NOW}
}


modify_version()
{ 
	echo 	modify_version...
	echo ${SOURCE_PATH}/${PRJ_PATH}
	cd ${SOURCE_PATH}/${PRJ_PATH}
	chmod 777 . -R
	
	echo "Modify Setting info..."
	DEVINFO=oppo/app/Settings/src/com/android/settings/DeviceInfoSettings.java
	chmod 777 ${DEVINFO}
	awk '{gsub(/1.01/,"'$BRANCH_NUM'");print}' ${DEVINFO} > DeviceInfoSettings_temp.java
	mv DeviceInfoSettings_temp.java ${DEVINFO}
	
	MTKCONF=mediatek/config/common/ProjectConfig.mk
	chmod 777 ${MTKCONF}
	awk '{gsub(/ALPS.JB2.TDD.MP.V1/,"'$BUILD_NUM_MTK'");print}' ${MTKCONF} > ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${MTKCONF}
	
	echo "Modify build time info..."
	CHKINFO=oppo/app/OppoEngineerMode/src/com/oppo/engineermode/CheckSoftwareInfo.java 
	chmod 777 ${CHKINFO}
	awk '{gsub(/3.0.35.7/,"3.4.5-'$SVN_VERSION_NOW'");print}' ${CHKINFO} > CheckSoftwareInfo_temp.java
	mv CheckSoftwareInfo_temp.java ${CHKINFO}
	awk '{gsub(/1.01/,"'$BRANCH_NUM'");print}' ${CHKINFO} > CheckSoftwareInfo_temp.java
	mv CheckSoftwareInfo_temp.java ${CHKINFO}
	
	echo "Modify build time info..."
	SFBTIME=oppo/app/OppoEngineerMode/src/com/oppo/engineermode/SoftwareBuildTime.java
	chmod 777 ${SFBTIME}
	awk '{gsub(/3.0.35.7/,"3.4.5-'$SVN_VERSION_NOW'");print}' ${SFBTIME} > SoftwareBuildTime_temp.java
	mv SoftwareBuildTime_temp.java ${SFBTIME}
}


modify_cmcc_config()
{
	cd $SOURCE_PATH/${PRJ_PATH}
	
	echo "modify version number MTK to R809T ->tree.xml<-"	
	TREE_PATH=mediatek/operator/OP01/prebuilt/MediatekDM/tree.xml
	chmod 777 ${TREE_PATH}
	awk '{gsub(/MTK/,"R809T");print}' ${TREE_PATH} > tree_temp.xml
	mv tree_temp.xml ${TREE_PATH}
	
	echo "Modify cmcctest value"
	PJC_PATH=mediatek/config/${PRJ_NAME}/OppoConfig.mk
	chmod 777 ${PJC_PATH}
	awk '{gsub(/^OPPO.CMCC.TEST.no$/,"OPPO_CMCC_TEST=no");print}' ${PJC_PATH} > ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PJC_PATH}
	
	echo "Modify OPPO_CMCC_OPTR -->yes to no"
	PJC_PATH=mediatek/config/${PRJ_NAME}/OppoConfig.mk
	chmod 777 ${PJC_PATH}
	awk '{gsub(/^OPPO.CMCC.OPTR...yes$/,"OPPO_CMCC_OPTR=no");print}' ${PJC_PATH} > ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PJC_PATH}
	
	echo "Modify cmccversion to no"
	echo "mediatek/config/${PRJ_NAME}/system.prop"
	SYSPROP=mediatek/config/${PRJ_NAME}/system.prop
	chmod 777 ${SYSPROP}
	awk '{gsub(/^persist.oppo.cmccversion.*/,"persist.oppo.cmccversion=0");print}' ${SYSPROP} > system.prop_temp
	mv system.prop_temp ${SYSPROP}
}


modify_version_usr()
{
	echo 	modify_version_usr... 	
	modify_version
	cd ${SOURCE_PATH}/${PRJ_PATH}
	
	echo "Modify ProjectConfig info..."
	PROCONF=build/target/product/${PRJ_NAME}.mk
	chmod 777 ${PROCONF}
	awk '{gsub(/OPPO.BUILD.VERNO....R809T/,"OPPO_BUILD_VERNO := '${SOFT_VERSION}'");print}' ${PROCONF}> ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PROCONF}
	awk '{gsub(/export.BUILD.VERSION.OTA.R809T/,"export BUILD_VERSION_OTA='${OTA_VERSION}'");print}' ${PROCONF}> ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PROCONF}
}


modify_code_usr()
{
	echo modify_code_usr...
	cd ${SOURCE_PATH}/${PRJ_PATH}
	echo ${SOURCE_PATH}/${PRJ_PATH}
	
	PJC_PATH=mediatek/config/${PRJ_NAME}/OppoConfig.mk
	echo "mediatek\config\\${PRJ_NAME}\ProjectConfig.mk"
	awk '{gsub(/^OPPO.BUILD.VARIANT.USER.*no$/,"OPPO_BUILD_VARIANT_USER=yes");print}' ${PJC_PATH} > OppoConfig_temp.mk
	mv OppoConfig_temp.mk ${PJC_PATH}
	
	ASS_PATH=frameworks/base/oppo/java/java/lang/ASSERT.java
	echo "frameworks\base\oppo\java\java\lang\ASSERT.java"
	awk '{gsub(/^.*Error.e.=.new.Error\(message\);$/,"//Error e = new Error(message);");print}' ${ASS_PATH} > ASSERT_temp.java
	awk '{gsub(/^.*fail\(e\);$/,"//fail(e);");print}' ASSERT_temp.java > ASSERT_temp1.java
	awk '{gsub(/^.*private.static.final.boolean.isAssertEnable...true;/,"private static final boolean isAssertEnable = false;");print}' ASSERT_temp1.java > ASSERT_temp2.java
	rm ASSERT_temp.java
	rm ASSERT_temp1.java
	mv ASSERT_temp2.java ${ASS_PATH}

	DBM_PATH=frameworks/base/services/java/com/android/server/DropBoxManagerService.java
	echo "frameworks\base\services\java\com\android\server\DropBoxManagerService.java"
	awk '{gsub(/^.*ASSERT\.epitaph\(temp,.tag,.flags\);$/,"//ASSERT.epitaph(temp, tag, flags);");print}' ${DBM_PATH} > DropBoxManagerService_temp.java
	mv DropBoxManagerService_temp.java ${DBM_PATH}	
}


compile_usr_new()
{
	cd $SOURCE_PATH/${PRJ_PATH}
	
	echo "compile user code..."
	./makeMtk -opt=TARGET_BUILD_VARIANT=user ${PRJ_NAME} new
	EXIT=$?

	if [ $EXIT != 0 ];then
		echo "Compile Failed! Please Check it."
		exit 0
	fi
}


compile_usr_ota()
{
	cd $SOURCE_PATH/${PRJ_PATH}
	echo "build ota ..."
	./makeMtk -opt=TARGET_BUILD_VARIANT=user ${PRJ_NAME} otapackage
}


package_usr_new()
{
	cd $SOURCE_PATH/$PRJ
	echo "package version..."
	mkdir out_img
	cp ${OUT_PATH}/* out_img/
	cp ${DATA_PATH} out_img/${BUILD_NUM_MTK}_database
	cp ${APDA_PATH} out_img/${BUILD_NUM_MTK}_database_AP
	rm out_img/*.zip
	mv out_img ${BUILD_NUM_MTK}
	tar chzf ${BUILD_NUM_MTK}.tar.gz ${BUILD_NUM_MTK}
	check_exit
}


package_ota()
{
	cd $SOURCE_PATH/${PRJ_PATH}
	mv ${OUT_PATH}/${PRJ_NAME}-ota-*wipedata.zip R809T_11.${BRANCH_NUM}_OTA_${OTA_SERIAL}_all_svn${SVN_VERSION_NOW}_wipe.zip	
	mv ${OUT_PATH}/${PRJ_NAME}-ota-*.zip R809T_11.${BRANCH_NUM}_OTA_${OTA_SERIAL}_all_svn${SVN_VERSION_NOW}.zip
}


copy_to_target()
{
	if [ -n "$TARGET_PATH" ] ;then
	cd $SOURCE_PATH/${PRJ_PATH}
	echo "copy to TARGET_PATH..."
	
	mv ${BUILD_NUM_MTK}.tar.gz ${TARGET_PATH}/
	mv R809T_11.${BRANCH_NUM}_OTA_*.zip ${TARGET_PATH}/
	cp ${OUT_PATH}/obj/PACKAGING/target_files_intermediates/OPPO*.zip svn${SVN_VERSION_NOW}_${BRANCH_NUM}_${OTA_SERIAL}.zip
	cp svn${SVN_VERSION_NOW}_${BRANCH_NUM}_${OTA_SERIAL}.zip ${TARGET_PATH}/

	fi
}


rm_local_version()
{
	echo "rm source and target"	
	rm -rf $SOURCE_PATH/${PRJ_PATH}
	rm -r $TARGET_PATH
}


#--------------------------------------------------------------------------------------------
echo -e "\n================================ Start ================================\n"
echo Now time=`date`
ALL_START_TIME=$(date +%s)


if [ $# != 2 ];then
	echo "Arguments are less or more than 1. Exit!"
	exit 0
else
	ARG_PROJECT=${1}
	SW_SVN_REVISION=${2}
fi


echo SOURCE_PATH = ${SOURCE_PATH}
echo TARGET_PATH = ${TARGET_PATH}
echo ARG_PROJECT=${ARG_PROJECT}

PROJECT=${ARG_PROJECT}

prj_init
#export_source_code
#modify_version_usr
#modify_cmcc_config
modify_code_usr
compile_usr_new
#compile_usr_ota
#package_usr_new
#package_ota
#copy_to_target
#copy_to_changan
#rm_local_version

ALL_END_TIME=$(date +%s)
ALL_DIFF=$((${ALL_END_TIME} - ${ALL_START_TIME}))
echo "**********All takes `expr ${ALL_DIFF} / 60` minutes `expr ${ALL_DIFF} % 60` seconds"
echo -e "\n================================ End ================================\n"
#--------------------------------------------------------------------------------------------



