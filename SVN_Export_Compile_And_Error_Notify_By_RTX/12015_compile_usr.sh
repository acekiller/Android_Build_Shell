#!/bin/bash
#gpeak,2012/07/23 for QE

#source ~/.profile
#LANG=zh_CN.UTF-8
#export LANG

DATE=`date +%F-%H`
BUILD_DATE=`date +%y%m%d`

##############################################################
#get base info of the project
##############################################################
get_svn_number(){
	if [ -z "$SVN_VERSION_NOW" ] ;then
	read -p "Honey,input SVN number:" SVN_VERSION_NOW
	fi
	echo SVN_VERSION_NOW=$SVN_VERSION_NOW	
}

get_soft_version(){
	if [ -z "$SOFT_VERSION" ] ;then
	read -p "Honey,input software version(1.01 2.01 3.01 ...):" SOFT_VERSION
	fi
	echo SOFT_VERSION=$SOFT_VERSION	
}

get_ota_version(){
	if [ -z "$OTA_VERSION" ] ;then
	read -p "Honey,input ota version(001 002 003 ...):" OTA_VERSION
	fi
	echo OTA_VERSION=$OTA_VERSION	
}

get_build_time(){
	if [ -z "$BUILD_TM" ] ;then
	BUILD_TM=`date +%H%M`
	fi
	echo BUILD_TM=$BUILD_TM	
}

#svn number
SVN_VERSION_NOW=$1
get_svn_number

#software version
SOFT_VERSION=$2
get_soft_version

#ota version
OTA_VERSION=$3
get_ota_version

#compile time
BUILD_TM=$4
get_build_time

#where is the output 
TARGET_PATH=$5

##############################################################
#help this need you modify
##############################################################
#project_name (12021 or 12015)
PROJCT=12015

#project name (oppo77_12021 or oppo77_12015)
PRJ_NAME=oppo77_12015

#baseline URL
BASE_URL=http://192.168.3.240/svn/oppo_swdp/ics2/development

#source code root dir
PRJ=development

#download source code here
SOURCE_PATH=/work/12015/QE/USR

#where is this script
SH=/work/12015/script

BUILD_NUM=T29_11_${SOFT_VERSION}_${BUILD_DATE}
OTA_NUM=T29_11_${SOFT_VERSION}_${OTA_VERSION}_${BUILD_DATE}

##############################################################
#paths in project
##############################################################
#database and database_AP
DATA_PATH=mediatek/custom/out/${PRJ_NAME}/modem/BPLGUI*
APDA_PATH=mediatek/source/cgen/APDB_MT6577_S01_MAIN2.1_W10.24

#project info such as soft version and ota number
DEVINFO=oppo/app/public/Settings/src/com/android/settings/DeviceInfoSettings.java
CHKINFO=oppo/app/service/EngineerMode/src/com/oppo/engineermode/CheckSoftwareInfo.java
PROCONF=build/target/product/${PRJ_NAME}.mk
MTKCONF=mediatek/config/common/ProjectConfig.mk

#compile output dir
OUT_PATH=out/target/product/${PRJ_NAME}

ASS_PATH=libcore/luni/src/main/java/java/lang/ASSERT.java
PJC_PATH=mediatek/config/${PRJ_NAME}/ProjectConfig.mk

##############################################################
#ok, let's go
##############################################################

echo ========================================================
echo time=`date`
echo ========================================================

check_exit() {
    EXIT=$?    
    echo EXIT=$EXIT
}

common_export_source(){
	echo "export source from SVN..."
	cd $SOURCE_PATH
	echo $PWD
	svn export -r $SVN_VERSION_NOW ${BASE_URL} -q
	check_exit
}

common_export_source_usr(){
	common_export_source
	mv ${PRJ} ${PRJ}_usr_${SVN_VERSION_NOW}
	PRJ=${PRJ}_usr_${SVN_VERSION_NOW}
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
modify_version_usr(){
	modify_version
	
	cd $SOURCE_PATH/$PRJ
	
	echo "Modify ProjectConfig info..."
	chmod 777 ${PROCONF}
	awk '{gsub(/OPPO.BUILD.VERNO....T29/,"OPPO_BUILD_VERNO := '${BUILD_NUM}'");print}' ${PROCONF}> ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PROCONF}
	awk '{gsub(/export.BUILD.VERSION.OTA.T29/,"export BUILD_VERSION_OTA='${OTA_NUM}'");print}' ${PROCONF}> ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PROCONF}
}
modify_code_usr(){
	cd $SOURCE_PATH/$PRJ
	
	echo "libcore\luni\src\main\java\java\lang\ASSERT.java"
	awk '{gsub(/^.*Error.e.=.new.Error\(message\);$/,"//Error e = new Error(message);");print}' ${ASS_PATH} > ASSERT_temp.java
	awk '{gsub(/^.*fail\(e\);$/,"//fail(e);");print}' ASSERT_temp.java > ASSERT_temp1.java
	awk '{gsub(/^.*private.static.final.boolean.isAssertEnable.*/,"private static final boolean isAssertEnable = false;");print}' ASSERT_temp1.java > ASSERT_temp2.java
	rm ASSERT_temp.java
	rm ASSERT_temp1.java
	mv ASSERT_temp2.java ${ASS_PATH}

	echo "mediatek\config\\${PJC_PATH}\ProjectConfig.mk"
	awk '{gsub(/^HAVE.AEE.FEATURE...yes$/,"HAVE_AEE_FEATURE=no");print}' ${PJC_PATH} > ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PJC_PATH}
	
	echo "mediatek\config\\${PJC_PATH}\ProjectConfig.mk"
	awk '{gsub(/^OPPO.BUILD.VARIANT.USER.*no$/,"OPPO_BUILD_VARIANT_USER=yes");print}' ${PJC_PATH} > ProjectConfig_temp.mk
	mv ProjectConfig_temp.mk ${PJC_PATH}
}

compile_usr_new(){
	cd $SOURCE_PATH/$PRJ
	echo "compile user code..."
	./makeMtk -opt=TARGET_BUILD_VARIANT=user ${PRJ_NAME} new
	EXIT=$?

	if [ $EXIT != 0 ];then
		echo "Compile Failed!"
		if [ -n "$TARGET_PATH" ] ;then
			mv ${TARGET_PATH} ${TARGET_PATH}_ERR
			cp ${OUT_PATH}_* ${TARGET_PATH}_ERR
		fi
		exit 0
	fi
}
compile_usr_ota(){
	cd $SOURCE_PATH/$PRJ
	echo "build ota ..."
	./makeMtk -opt=TARGET_BUILD_VARIANT=user ${PRJ_NAME} otapackage
}


package_usr_new(){
	cd $SOURCE_PATH/$PRJ
	echo "package version..."
	mkdir out_img
	cp ${OUT_PATH}/* out_img/
	cp ${DATA_PATH} out_img/${BUILD_NUM}_database
	cp ${APDA_PATH} out_img/${BUILD_NUM}_database_AP
	rm out_img/*.zip
	mv out_img SVN${SVN_VERSION_NOW}_${BUILD_DATE}
	tar chzf ${BUILD_NUM}.tar.gz SVN${SVN_VERSION_NOW}_${BUILD_DATE}
	check_exit
}
package_ota(){
	cd $SOURCE_PATH/$PRJ
	cp ${OUT_PATH}/${PRJ_NAME}-ota-*.root.zip T29_11_OTA_${OTA_VERSION}_all_SVN${SVN_VERSION_NOW}.zip
	cp ${OUT_PATH}/${PRJ_NAME}-ota-*.root_wipedata.zip T29_11_OTA_${OTA_VERSION}_all_SVN${SVN_VERSION_NOW}_wipe.zip
}

copy_to_target(){
	if [ -n "$TARGET_PATH" ] ;then
	cd $SOURCE_PATH/$PRJ
	mv ${BUILD_NUM}.tar.gz ${TARGET_PATH}/
	mv T29_11_OTA_*.zip ${TARGET_PATH}/
	fi
}
	
common_export_source_usr
modify_version_usr
modify_code_usr
compile_usr_new
compile_usr_ota
package_usr_new
package_ota
copy_to_target


