#!/bin/bash
#gpeak,2012/07/23 for QE

DATE=`date +%F-%H`
BUILD_DATE=`date +%y%m%d`

##############################################################
#help need you !need you !need you !need you !need you !
##############################################################
#where are these scripts
SH=/work/12015/script

#where is the output 
TARGET_PATH=/work/12015/QE/OUT

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

TARGET_PATH=${TARGET_PATH}/${BUILD_DATE}_${BUILD_TM}
mkdir ${TARGET_PATH}

source ${SH}/12015_compile_eng.sh ${SVN_VERSION_NOW} ${SOFT_VERSION} ${OTA_VERSION} ${BUILD_TM} ${TARGET_PATH} &
source ${SH}/12015_compile_usr.sh ${SVN_VERSION_NOW} ${SOFT_VERSION} ${OTA_VERSION} ${BUILD_TM} ${TARGET_PATH} &