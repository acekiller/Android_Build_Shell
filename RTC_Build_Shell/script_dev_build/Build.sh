#!/bin/bash
#
#

#========================================== Usefull Tools Begin ==========================================
fn_rm()
{
    if [ -f ${1} ];then
        echo "INFO:**********Delete file : ${1}"
        rm -f ${1}
    fi
    
    if [ -d ${1} ];then
        echo "INFO:**********Delete folder : ${1}"
        rm -rf ${1}
    fi
}

fn_check_error()
{
	local result=$?
	if [ ${result} != ${EXEC_SUCCESS} ];then
		echo "ERR:**********Error occured. Exit!"
		exit ${result}
	fi
}

fn_change_dir_to()
{
	local destination_dir=${1}
	echo "INFO:**********Change dir to : ${destination_dir}"
	if [ -d ${destination_dir} ];then
		cd ${destination_dir}
		fn_check_error
	else
		echo "ERR:**********Dir ${destination_dir} is not exist. Exit!"
		exit ${EXEC_FAILED}
	fi
}

fn_copy_dir_to()
{
	echo "INFO:**********fn_copy_dir_to : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	local source_dir=${1}
	local destination_path=${2}
	if [ ! -d ${source_dir} ];then
		echo "ERR:**********Dir : ${source_dir} is not exist. Exit!"
		exit ${EXEC_FAILED}
	fi
	
	if [ ! -d ${destination_path} ];then
		mkdir -p ${destination_path}
	fi
	
	cp -rf ${source_dir} ${destination_path}
	fn_check_error
	############################################################################
	echo "INFO:**********fn_copy_dir_to : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"

}

fn_copy_dir()
{
	echo "INFO:**********fn_copy_dir : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	local source_dir=${1}
	local destination_path=${2}
	echo "INFO:**********Copy dir : ${source_dir} to ${destination_path}"
	if [ ! -d ${source_dir} ];then
		echo "ERR:**********Dir : ${source_dir} is not exist. Exit!"
		exit ${EXEC_FAILED}
	fi
	
	if [ ! -d ${destination_path} ];then
		mkdir -p ${destination_path}
	else
		echo "INFO:**********Delete dir first : ${destination_path}/*"
		rm -rf ${destination_path}/*
	fi
	
	cp -rf ${source_dir} ${destination_path}
	fn_check_error
	chmod -R 777 ${destination_path}
	############################################################################
	echo "INFO:**********fn_copy_dir : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_copy_file()
{
	local source_file=${1}
	local destination_path=${2}
	
	echo "INFO:**********Copy file : ${source_file} to ${destination_path}"
	if [ ! -f ${source_file} ];then
		echo "ERR:**********File ${source_file} is not exist. Exit!"
		exit ${EXEC_FAILED}
	fi
	if [ ! -d ${destination_path} ];then
		mkdir -p ${destination_path}
	fi
	
	cp -f ${source_file} ${destination_path}
	fn_check_error
}

fn_export_global_var()
{
    export RTC_SCM_URL
    export RTC_SCM_USER
    export RTC_SCM_PASSWORD
    export WORKSPACE
    export COMPS_SRC_CODE_ROOT_DIR_PATH
    export COMPS_SRC_CODE_ENV_PATH
}

fn_unset_global_var()
{
	unset RTC_SCM_URL
	unset RTC_SCM_USER
	unset RTC_SCM_PASSWORD
	unset WORKSPACE
	unset COMPS_SRC_CODE_ROOT_DIR_PATH
	unset COMPS_SRC_CODE_ENV_PATH
}

fn_rtc_login()
{
	echo "INFO:**********Login RTC..."
	scm login -r ${RTC_SCM_URL} -u ${RTC_SCM_USER} -P ${RTC_SCM_PASSWORD} #-n ${RTC_SCM_ALIAS} #>/dev/null 2>&1
	fn_check_error
}

fn_rtc_logout()
{
	echo "INFO:**********Logout RTC..."
	scm logout -r ${RTC_SCM_URL}
	fn_check_error
}
fn_print_parameters()
{
	echo "fn_print_parameters..."
	echo "PRODUCT_NAME               : ${PRODUCT_NAME}"
	echo "SWITCH_GET                 : ${SWITCH_GET}"
	echo "SWITCH_MAKE                : ${SWITCH_MAKE}"
	echo "SWITCH_TAR"                : ${SWITCH_TAR}
	echo "SWITCH_DISTRIBUTE          : ${SWITCH_DISTRIBUTE}"
}

fn_check_ws_state()
{
	echo -e "\nfn_check_ws_state... : ${1} ${2}\n"

	if [ "${1}" = "Workspace" -a "${2}" = "unchanged." ]; then
		echo "Workspace unchanged, so no need to trigger build."
		WS_UNCHANGED=1
	else
		echo "Workspace changed."
		WS_UNCHANGED=0
	fi
}

fn_get_snapshot()
{
	echo -e "	\nfn_get_snapshot..."

	if [ ${IS_RELEASE} == 0 ];then
		echo "tempversion"
	elif [ ${IS_RELEASE} == 1 ];then
		rtc_sn=$(scm list ss -r ${RTC_SCM_ALIAS} -m 1 ${WORKSPACE_SZ})
		fn_check_error
		ss_name_nofront=${rtc_sn#*\"}
		ss_name=${ss_name_nofront%%\"*}

		ss_id_nofront=${rtc_sn#*\(}
		ss_id=${ss_id_nofront%%\)*}
	elif [ ${IS_RELEASE} == 2 ];then
		echo "-----sync code has been done before runing build.sh-----"
		exit ${EXEC_FAILED}
	fi

	echo "Snapshot : ${ss_name}"
	version_name="${ss_name}"
}

fn_create_snapshot()
{
	echo -e "	\nfn_create_snapshot : Create snapshot."

	ss_name=`date +${PRJ_NAME}_NEW_%Y%m%d-%H%M`
	echo "ss_name : ${ss_name}"
	
	version_name="${ss_name}"
	echo "version_name : ${version_name}"
	echo "scm cr ss -r ${RTC_SCM_ALIAS} -n ${ss_name} ${WORKSPACE_ERROR}"
	scm cr ss -r ${RTC_SCM_ALIAS} -n ${ss_name} ${WORKSPACE_ERROR}
	fn_check_error
}
#========================================== Usefull Tools End ==========================================

#============================== Get Source Code Interface Introduction Begin =================================
fn_accept_code()
{
	echo "INFO:**********fn_accept_code : Begining..."
	local begin_time=$(date +%s)
	############################################################################	
	if [ ! -d "${COMPS_SRC_CODE_ROOT_DIR_PATH}/.jazz5" ]; then
		echo "ERR:**********There is no sandbox in ${COMPS_SRC_CODE_ROOT_DIR_PATH}. Exit!"
		exit ${EXEC_FAILED}
	fi
	fn_change_dir_to "${COMPS_SRC_CODE_ROOT_DIR_PATH}"
	local accept_result=`scm accept -o`
	echo "INFO:**********accept_result : ${accept_result}"
	fn_check_ws_state ${accept_result}
	fn_change_dir_to "${CURRENT_PATH}"
	if [ ${WS_UNCHANGED} = 1 ]; then
		exit ${EXEC_SUCCESS}
	fi
	############################################################################
	echo "INFO:**********fn_accept_code : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"	
}

fn_load_all_code()
{
	echo "INFO:**********fn_load_all_code : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	if [ ! -d "${COMPS_SRC_CODE_ROOT_DIR_PATH}" ]; then
		mkdir -p "${COMPS_SRC_CODE_ROOT_DIR_PATH}"
	fi
	fn_change_dir_to "${COMPS_SRC_CODE_ROOT_DIR_PATH}"
	if [ -d "${COMPS_SRC_CODE_ENV_PATH}" ]; then
		rm -rf ${COMPS_SRC_CODE_ROOT_DIR_PATH}/*
		rm -rf ${COMPS_SRC_CODE_ROOT_DIR_PATH}/.jazz5/
		rm -rf ${COMPS_SRC_CODE_ROOT_DIR_PATH}/.metadata/
	fi
	bash ${SCRIPT_DIR_PATH}/Load_All_Comps.sh ${SCRIPT_DIR_PATH}/${COMPS_MAP_CONFIG_FILE_NAME}
	fn_check_error
	fn_change_dir_to "${CURRENT_PATH}"
	############################################################################
	echo "INFO:**********fn_load_all_code : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"	
}

fn_get_source()
{
	echo "INFO:**********fn_get_source : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	# 1 : Accept code.
	# 2 : Load all code.
	# 3 : Just copy code to build destination.
	# 4 : Accept and copy code to build destination.
	# 5 : Load and copy code to build destination.
	############################################################################
	local Pure_Accept=1; local Pure_Load=2; local Pure_Copy=3;
	local Accpet_And_Copy=4; local Load_And_Copy=5;
	
	if [ ${SWITCH_GET} == ${Pure_Accept} ]; then
		fn_accept_code
	elif [ ${SWITCH_GET} == ${Pure_Load} ]; then
		fn_load_all_code
	elif [ ${SWITCH_GET} == ${Pure_Copy} ]; then
		fn_copy_dir "${COMPS_SRC_CODE_ENV_PATH}" "${BUILD_SRC_CODE_ROOT_PATH}"
	elif [ ${SWITCH_GET} == ${Accpet_And_Copy} ]; then
		fn_accept_code
		fn_copy_dir "${COMPS_SRC_CODE_ENV_PATH}" "${BUILD_SRC_CODE_ROOT_PATH}"
	elif [ ${SWITCH_GET} == ${Load_And_Copy} ]; then
		fn_load_all_code
		fn_copy_dir "${COMPS_SRC_CODE_ENV_PATH}" "${BUILD_SRC_CODE_ROOT_PATH}"
	else
		echo "ERR:**********Unknown command. Exit!"
		exit ${EXEC_FAILED}
	fi
	############################################################################
	echo "INFO:**********fn_get_source : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}
#============================== Get Source Code Interface Introduction End ===================================

#============================== Make Source Code Interface Introduction Begin ================================
fn_make_android()
{
	echo "INFO:**********fn_make_android : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	fn_change_dir_to "${BUILD_ANDROID_ENV_PATH}"


	fn_change_dir_to "${CURRENT_PATH}"
	############################################################################
	echo "INFO:**********fn_make_android : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_remake_android()
{
	echo "INFO:**********fn_remake_android : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	fn_change_dir_to "${BUILD_ANDROID_ENV_PATH}"


	fn_change_dir_to "${CURRENT_PATH}"
	############################################################################
	echo "INFO:**********fn_remake_android : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_make_modem()
{
	echo "INFO:**********fn_make_modem : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	fn_change_dir_to "${BUILD_MODEM_ENV_PATH}"


	fn_change_dir_to "${CURRENT_PATH}"	
	############################################################################
	echo "INFO:**********fn_make_modem : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_make_source()
{
	echo "INFO:**********fn_make_source : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	# 1 : Make Modem
	# 2 : Make Android
	# 3 : Make Android and Modem
	# 4 : Remake Android
	############################################################################
	local Make_Modem=1; local Make_Android=2; local Make_All=3;
	local Remake_Android=4;
	
	if [ ${SWITCH_MAKE} == ${Make_Modem} ]; then
		fn_make_modem
	elif [ ${SWITCH_MAKE} == ${Make_Android} ]; then
		fn_make_android
	elif [ ${SWITCH_MAKE} == ${Make_All} ]; then
		fn_make_modem
		fn_make_android
	elif [ ${SWITCH_MAKE} == ${Remake_Android} ]; then
		fn_remake_android
	else
		echo "INFO:**********Unknown command. Exit!"
		exit ${EXEC_FAILED}
	fi
	############################################################################
	echo "INFO:**********fn_make_source : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}
#============================== Make Source Code Interface Introduction End ==================================

#============================== TAR Source Code Interface Introduction Begin =================================
fn_tar_sdk()
{
	echo "INFO:**********fn_tar_sdk : Begining..."
	local begin_time=$(date +%s)
	############################################################################


	############################################################################
	echo "INFO:**********fn_tar_sdk : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_tar_images()
{
	echo "INFO:**********fn_tar_images : Begining..."
	local begin_time=$(date +%s)
	############################################################################


	############################################################################
	echo "INFO:**********fn_tar_images : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_tar_source()
{
	echo "INFO:**********fn_tar_source : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	# 1 : TAR SDK
	# 2 : TAR Images
	# 3 : TAR SDK And Images
	############################################################################
	local Tar_Sdk=1; local Tar_Images=2; local Tar_Sdk_And_Images=3;
	
	if [ ${SWITCH_TAR} == ${Tar_Sdk} ]; then
		fn_tar_sdk
	elif [ ${SWITCH_TAR} == ${Tar_Images} ]; then
		fn_tar_images
	elif [ ${SWITCH_TAR} == ${Tar_Sdk_And_Images} ]; then
		fn_tar_sdk
		fn_tar_images
	else
		echo "ERR:**********Unknown command. Exit!"
		exit ${EXEC_FAILED}		
	fi
	############################################################################
	echo "INFO:**********fn_tar_source : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}
#============================== TAR Source Code Interface Introduction End ===================================

#========================== Distribute Source Code Interface Introduction Begin ==============================
fn_distribute_sdk()
{
	echo "INFO:**********fn_distribute_sdk : Begining..."
	local begin_time=$(date +%s)
	############################################################################

	############################################################################
	echo "INFO:**********fn_distribute_sdk : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_distribute_images()
{
	echo "INFO:**********fn_distribute_images : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	
	############################################################################
	echo "INFO:**********fn_distribute_images : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}

fn_distribute_source()
{
	echo "INFO:**********fn_distribute_source : Begining..."
	local begin_time=$(date +%s)
	############################################################################
	# 1 : Distribute SDK
	# 2 : Distribute Images
	# 3 : Distribute SDK And Images
	############################################################################
	local Dis_Sdk=1; local Dis_Images=2; local Dis_Sdk_And_Images=3;
	
	if [ ${SWITCH_DISTRIBUTE} == ${Dis_Sdk} ]; then
		fn_distribute_sdk
	elif [ ${SWITCH_DISTRIBUTE} == ${Dis_Images} ]; then
		fn_distribute_images
	elif [ ${SWITCH_DISTRIBUTE} == ${Dis_Sdk_And_Images} ]; then
		fn_distribute_sdk
		fn_distribute_images
	else
		echo "ERR:**********Unknown command. Exit!"
		exit ${EXEC_FAILED}			
	fi
	############################################################################
	echo "INFO:**********fn_distribute_source : Ended!"
	local end_time=$(date +%s)
	local diff=$(( ${end_time} - ${begin_time} ))
	echo -e "INFO:**********It takes `expr ${diff} / 60` minutes and `expr ${diff} % 60` seconds \n"
}
#========================== Distribute Source Code Interface Introduction End ================================

#**************************************** Main Entry *****************************************
echo -e "\n================================== Main Entry ==================================\n"
EXEC_SUCCESS=0
EXEC_FAILED=1
#===========================================================================================
if [ $# != 5 ];then
	echo "INFO:**********Arguments are less or more than 5. Exit!"
	exit ${EXEC_FAILED}
else
	PRODUCT_NAME=${1}
	SWITCH_GET=${2}
	SWITCH_MAKE=${3}
	SWITCH_TAR=${4}
	SWITCH_DISTRIBUTE=${5}
fi
#============================== Declare Global Variable ====================================
CURRENT_PATH=`pwd`
SCRIPT_DIR_PATH="${CURRENT_PATH}/script_dev_build"
. ${SCRIPT_DIR_PATH}/Project_Config.sh
#===========================================================================================

ALL_START_TIME=$(date +%s)

fn_rtc_login

fn_print_parameters

fn_export_global_var

if [ ${SWITCH_GET} != 0 ]; then
	fn_get_source
fi

if [ ${SWITCH_MAKE} != 0 ]; then
	fn_make_source
fi

if [ ${SWITCH_TAR} != 0 ]; then
	fn_tar_source
fi

if [ ${SWITCH_DISTRIBUTE} != 0 ]; then
	fn_distribute_source
fi

fn_rtc_logout

fn_unset_global_var

ALL_END_TIME=$(date +%s)
ALL_DIFF=$(( $ALL_END_TIME - $ALL_START_TIME ))
echo -e "\nINFO:**********All the process takes `expr ${ALL_DIFF} / 60` minutes and `expr ${ALL_DIFF} % 60` seconds \n"
echo -e "================================== End ==================================\n"

#*******************************************************************************************************
