#!/bin/bash
#
#

#===============================================================================
PACKAGES_DIR_PATH="${COMPS_SRC_CODE_ENV_PATH}/android/packages"
APPS_DIR_PATH="${PACKAGES_DIR_PATH}/apps"
PROVIDERS_DIR_PATH="${PACKAGES_DIR_PATH}/providers"
WALLPAPERS_DIR_PATH="${PACKAGES_DIR_PATH}/wallpapers"
SYSTEM_DIR_PATH="${COMPS_SRC_CODE_ENV_PATH}/android/system"
EXTERNAL_PATH="${COMPS_SRC_CODE_ENV_PATH}/android/external"

#===============================================================================

#===============================================================================
COMPS_MAP_CFG_FILE="${1}"
comps_array=(`cat ${COMPS_MAP_CFG_FILE}`)
LENGTH=${#comps_array[@]}

#===============================================================================
fn_loading()
{
	echo "INFO:**********fn_loading..."
	# Load compnents up to 3 times
	MIN=1; MAX=3; EXIT=0
	echo "INFO:**********comp_load_to_dir : ${1}   comp_name : ${2}"
	while [ $MIN -le $MAX ] ; do
		scm load -r ${RTC_SCM_URL} -u ${RTC_SCM_USER} -P ${RTC_SCM_PASSWORD} -f -t ${1}/ ${WORKSPACE} ${2} #>/dev/null 2>&1
		EXIT=$?
		MIN=`expr $MIN + 1`
		if [ ${EXIT} == 0 ] ; then
			echo "INFO:**********load ${2} successed"
			break
		fi
	done
	if [ ${EXIT} != 0 ] ; then
		echo "INFO:**********Load ${2} failed, exit code is ${EXIT}. Exit!"
		exit ${EXIT}
	fi  
}

fn_create_special_dir()
{
	echo "INFO:**********fn_create_special_dir..."
	if [ ! -d "${COMPS_SRC_CODE_ENV_PATH}" ];then
		echo "INFO:**********create dir : ${COMPS_SRC_CODE_ENV_PATH}"
		mkdir -p "${COMPS_SRC_CODE_ENV_PATH}"
	else 
		echo "INFO:**********dir:${COMPS_SRC_CODE_ENV_PATH} is exist."
	fi
	
	if [ -d "${PACKAGES_DIR_PATH}" ]; then
		echo "INFO:**********${PACKAGES_DIR_PATH} is already exist"
	else
		echo "INFO:**********create dir:${PACKAGES_DIR_PATH}"
		mkdir -p "${PACKAGES_DIR_PATH}"
		
		if [ -d "${APPS_DIR_PATH}" ]; then
			echo "INFO:**********${APPS_DIR_PATH} is already exist"
		else
			echo "INFO:**********create dir:${APPS_DIR_PATH}"
			mkdir -p "${APPS_DIR_PATH}"
		fi
		
		if [ -d "${PROVIDERS_DIR_PATH}" ]; then
			echo "INFO:**********${PROVIDERS_DIR_PATH} is already exist"
		else
			echo "INFO:**********create dir:${PROVIDERS_DIR_PATH}"
			mkdir -p "${PROVIDERS_DIR_PATH}"
		fi
	
		if [ -d "${WALLPAPERS_DIR_PATH}" ]; then
			echo "INFO:**********${WALLPAPERS_DIR_PATH} is already exist"
		else
			echo "INFO:**********create ${WALLPAPERS_DIR_PATH}"
			mkdir -p "${WALLPAPERS_DIR_PATH}"
		fi
	fi
	
	if [ -d "${SYSTEM_DIR_PATH}" ]; then
		echo "INFO:**********${SYSTEM_DIR_PATH} is already exist"
	else
		echo "INFO:**********create dir:${SYSTEM_DIR_PATH}"
		mkdir -p "${SYSTEM_DIR_PATH}"
	fi
	
	if [ -d "${EXTERNAL_PATH}" ]; then
		echo "INFO:**********${EXTERNAL_PATH} is already exist"
	else
		echo "INFO:**********create dir:${EXTERNAL_PATH}"
		mkdir -p "${EXTERNAL_PATH}"
	fi
	################################################################################################
	# Add begin by long.luo 2012/07/10, for create the OPPO comps directory.
	#if [ -d "${OPPO_DIR_PATH}" ]; then
	#	echo "${OPPO_DIR_PATH} is already exist"
	#else
	#	echo "create dir:${OPPO_DIR_PATH}"
	#	mkdir "${OPPO_DIR_PATH}"
	#
	#	if [ -d "${OPPO_APP_PATH}" ]; then
	#		echo "${OPPO_APP_PATH} is already exist"
	#	else
	#		echo "create dir:${OPPO_APP_PATH}"
	#		mkdir "${OPPO_APP_PATH}"
	#	fi
	#
	#	if [ -d "${OPPO_FRAMEWORK_PATH}" ]; then
	#		echo "${OPPO_FRAMEWORK_PATH} is already exist"
	#	else
	#		echo "create dir:${OPPO_FRAMEWORK_PATH}"
	#		mkdir "${OPPO_FRAMEWORK_PATH}"
	#	fi
	#
	#	if [ -d "${OPPO_OPPOAPK_PATH}" ]; then
	#		echo "${OPPO_OPPOAPK_PATH} is already exist"
	#	else
	#		echo "create ${OPPO_OPPOAPK_PATH}"
	#		mkdir "${OPPO_OPPOAPK_PATH}"
	#	fi
	#	
	#	if [ -d "${OPPO_SYSTEM_PATH}" ]; then
	#		echo "${OPPO_SYSTEM_PATH} is already exist"
	#	else
	#		echo "create ${OPPO_SYSTEM_PATH}"
	#		mkdir "${OPPO_SYSTEM_PATH}"
	#	fi
	#fi
	# Add end by long.luo 2012/07/10.
	################################################################################################
}

fn_load_components()
{
	echo "INFO:**********fn_load_components : starting load comps..."
	for ((i=0; i<${LENGTH}; i++))
	do
		j=`expr ${i} + 1`
		fn_loading "${COMPS_SRC_CODE_ROOT_DIR_PATH}/${comps_array[${i}]%/*}" "${comps_array[${j}]}"
		i=`expr ${i} + 1`
	done
}

#start point
echo "INFO:**********COMPS_SRC_CODE_ENV_PATH:${COMPS_SRC_CODE_ENV_PATH}"
fn_create_special_dir
fn_load_components
