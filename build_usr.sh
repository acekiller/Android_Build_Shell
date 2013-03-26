#!/bin/bash
#
#  File:
#		build_usr.sh
#
#	Description:
#		Used to export the code and compile.
#
#	History:
#		long.luo, 2013/03/25, modified.
#


#--------------------------------------------------------------------------------------------
#
PROJECT=${1}

# target path
SRC_PATH=`pwd`

# source code root dir
PRJ_PATH=development_mp

# project name
PRJ_NAME=OPPO89T_${PROJECT}

# out path
OUT_PATH=out


#--------------------------------------------------------------------------------------------
check_exit() 
{
    EXIT=$?    
    echo EXIT=$EXIT
}


modify_code_usr()
{
	echo "	modify_code_usr..."
	cd ${SRC_PATH}/${PRJ_PATH}
	echo cd ${SRC_PATH}/${PRJ_PATH}
	
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
	echo "	compile_usr_new..."
	cd ${SRC_PATH}/${PRJ_PATH}
	
	echo "compile user code..."
	./makeMtk -opt=TARGET_BUILD_VARIANT=user ${PRJ_NAME} new
	EXIT=$?

	if [ $EXIT != 0 ];then
		echo "Compile Failed! Please Check it."
		exit 0
	fi
}


chmod_out_path()
{
	echo "	chmod_out_path..."
	chmod -R 777 ${OUT_PATH}
}


#--------------------------------------------------------------------------------------------
modify_code_usr
compile_usr_new
chmod_out_path
#--------------------------------------------------------------------------------------------
