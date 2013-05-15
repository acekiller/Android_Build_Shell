#!/bin/bash
#gpeak,2012/01/07 for QE

source ~/.profile
LANG=zh_CN.UTF-8
export LANG

TARGET_RM_PATH=/work/12015/OUT
OUT_RM_PATH=/mnt/186server/12015/daily_build

TARGET_RM=`date -d "1 days ago" +%F`
OUT_RM=`date -d "4 days ago" +%F`

#cd ${TARGET_RM_PATH}
#rm -r ${TARGET_RM}*
cd ${OUT_RM_PATH}
rm ${OUT_RM}*/out*
