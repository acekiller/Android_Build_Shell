@echo off
echo ==================================================================
echo 功能：清除手机上的LOG文件，请定时清除手机上的LOG!
echo 注意 1) 清除前连上ADB
echo      2) 清除前建议把MTKLOG关闭(MTK平台手机)
echo      3) 本脚本适用于Android智能手机
echo  ---------------------------------------                         
echo 
echo  ---------------------------------------  
echo =================================================================

adb remount

adb shell rm -r /cache/assertlog
adb shell rm -r /data/anr
rem adb shell rm -r /data/tombstones

for /F  %%i in ('adb shell ls /data/tombstones/') do (
	set "thisline=%%i"
	SETLOCAL EnableDelayedExpansion
	set "shortthisline=!thisline:~0,-1!"
	echo !shortthisline!
	adb shell rm -r /data/tombstones/!shortthisline!
	ENDLOCAL
)

rem adb shell rm -r /sdcard/mtklog
for /F  %%i in ('adb shell ls /sdcard/mtklog/') do (
	set "thisline=%%i"
	SETLOCAL EnableDelayedExpansion
	set "shortthisline=!thisline:~0,-1!"
	if !shortthisline!==mdlog (echo mdlog) else (adb shell rm -r /sdcard/mtklog/!shortthisline!)	
	ENDLOCAL
)

for /F  %%i in ('adb shell ls /sdcard/mtklog/mdlog/') do (
	set "thisline=%%i"
	SETLOCAL EnableDelayedExpansion
	set "shortthisline=!thisline:~0,-1!"
	if !shortthisline!==catcher_filter.bin (echo catcher_filter.bin) else (adb shell rm -r /sdcard/mtklog/mdlog/!shortthisline!)	
	ENDLOCAL
)

for /F  %%i in ('adb shell ls /sdcard/external_sd/mtklog/') do (
	set "thisline=%%i"
	SETLOCAL EnableDelayedExpansion
	set "shortthisline=!thisline:~0,-1!"
	if !shortthisline!==mdlog (echo mdlog) else (adb shell rm -r /sdcard/external_sd/mtklog/!shortthisline!)	
	ENDLOCAL
)

for /F  %%i in ('adb shell ls /sdcard/external_sd/mtklog/mdlog/') do (
	set "thisline=%%i"
	SETLOCAL EnableDelayedExpansion
	set "shortthisline=!thisline:~0,-1!"
	if !shortthisline!==catcher_filter.bin (echo catcher_filter.bin) else (adb shell rm -r /sdcard/external_sd/mtklog/mdlog/!shortthisline!)	
	ENDLOCAL
)


rem for Qualcomm Log
adb shell rm -r /cache/admin
adb shell rm -r /sdcard/admin
adb shell rm -r /sdcard/external_sd/admin

adb shell rm -r /data/aee_exp

adb shell rm -r /data/core

adb shell rm -r /sdcard/screencapture
adb shell rm -r /sdcard/Pictures/Screenshots
adb shell rm -r /sdcard/灞忓箷鎴浘
adb shell rm -r /sdcard/external_sd/灞忓箷鎴浘

adb shell rm -r /data/data/com.mediatek.engineermode/files/oppoMobileLog
adb shell rm -r /mnt/sdcard/oppoMobileLog
adb shell rm -r /mnt/sdcard/external_sd/oppoMobileLog
adb shell rm -r /data/bootlog

adb shell rm -r /sdcard/dump_networking
adb shell rm -r /mnt/sdcard/external_sd/dump_networking
adb shell rm -r /data/dump_networking

adb logcat -c

echo =========================================
echo 		完成清除！
echo =========================================

pause

@echo on