@echo off

echo =========================================================
echo ���ܣ���ȡ�ֻ��ϵ�LOG�ļ�
echo ע�� 1) ��ȡǰ����ADB
echo      2) ��ȡǰ�����MTKLOG�ر�(MTKƽ̨�ֻ�)
echo      3) ����BUGʱ���뾡���ܽ���ͼƬ(11059��11091��11071��
echo         12007��������menu��,12009���Ժ����ͬʱ���µ�Դ��
echo         �������¼������ϼ���)�Ա������  
echo      4) ���ű�������Android�����ֻ�
echo  ---------------------------------------                 
echo
echo  ---------------------------------------                 
echo =========================================================


set "CURR_TIME=%date:~,4%_%date:~5,2%_%date:~8,2%_%time:~,2%_%time:~3,2%_%time:~6,2%"

set DEST_DIR=d:\log\log_pack_%CURR_TIME%\

md "%DEST_DIR%"
cd  /d  "%DEST_DIR%"

rem ==begin.....

adb pull /cache/assertlog  oppo_assertlog
adb pull /data/anr  anr
adb pull /data/tombstones  tombstones
adb pull /data/core  data_core

adb pull /sdcard/screencapture  screen_capture
adb pull /sdcard/Pictures/Screenshots  Screenshots

adb pull /sdcard/屏幕截图  ��Ļ��ͼ
adb pull /sdcard/external_sd/屏幕截图  ��Ļ��ͼ

adb pull /sdcard/mtklog mtklog
adb pull /sdcard/external_sd/mtklog mtklog


rem for Qualcomm Log
adb pull /cache/admin Qualcommlog
adb pull /sdcard/admin Qualcommlog
adb pull /sdcard/external_sd/admin Qualcommlog


rem =======read log from phone storage begin ====
if not exist mtklog md mtklog
adb pull /data/aee_exp mtklog/aee_exp-phone
rem =======read log from phone storage end ====

rmdir mtklog

rem ===================== get oppo log begin ===========================
adb pull /data/data/com.mediatek.engineermode/files/oppoMobileLog oppoMobileLog-phone

if not exist oppoMobileLog-phone md oppoMobileLog-phone
adb pull /data/bootlog oppoMobileLog-phone/bootlog
rmdir oppoMobileLog-phone

adb pull /mnt/sdcard/oppoMobileLog oppoMobileLog
adb pull /mnt/sdcard/external_sd/oppoMobileLog oppoMobileLog
rem ===================== get oppo log end    ===========================

rem ===================== get netlog begin ===========================
rem for MTK legency platform
adb pull /sdcard/dump_networking dump_networking
adb pull /mnt/sdcard/external_sd/dump_networking dump_networking


adb pull /data/dump_networking dump_networking-phone
rem ===================== get netlog log end    ======================

rem =====================state info begin===========================
rem echo dump phone state, please wait...
rem adb shell dumpstate > dumpstate.txt
rem echo dump phone state successfully!
rem =====================state info end=============================

cd ..
rmdir %DEST_DIR%

if exist "%DEST_DIR%" goto finish
echo ============================================================
echo  ��ȡLOGʧ�ܣ��п���ADBû���ϻ��ֻ���û��LOG���ڣ�����
echo ============================================================
goto exit

:finish
echo ============================================================
echo  �뵽Ŀ¼--"%DEST_DIR%"--�»�ȡLOG��
echo ============================================================

:exit
pause

@echo on