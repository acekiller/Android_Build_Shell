#!/bin/bash
#
#

#====================================== RTC Config =======================================
RTC_SCM_USER="rtc_cm_dlt"
RTC_SCM_PASSWORD="rtc_cm_dlt"
RTC_SCM_URL="https://rtc1:9444/ccm/"
#RTC_SCM_ALIAS="local"
STREAM="12001_Beta"
WORKSPACE="12001_Dev_WS"

#=========================================================================================

#==================================== Project Config =====================================
# Used create snapshot
PRJ_NAME="12001"
COMPS_MAP_CONFIG_FILE_NAME="Comps_Map.conf"
COMPS_SRC_CODE_ROOT_DIR_PATH="${PWD}/Comps_Src_Code"
COMPS_SRC_CODE_ENV_PATH="${COMPS_SRC_CODE_ROOT_DIR_PATH}/environment"
BUILD_SRC_CODE_ROOT_PATH="${PWD}/Build_Src_Code"
BUILD_SRC_CODE_ENV_PATH="${BUILD_SRC_CODE_ROOT_PATH}/environment"
BUILD_ANDROID_ENV_PATH="${BUILD_SRC_CODE_ENV_PATH}/android"
BUILD_MODEM_ENV_PATH="${BUILD_SRC_CODE_ENV_PATH}/branches"
#OUT_PATH="${COMPS_SRC_CODE_ENV_PATH}/target/product/${PRODUCT_NAME}"
#=========================================================================================
