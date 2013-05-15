@echo off 
title ADB Install Apks[By LongLuo]
goto BEGIN

:COMMENT
echo ##############################################
rem 	adb_install_apks.bat
rem			By Long.Luo @2013/03/20
rem		
rem 	Description:
rem 		Used to install all the apks in a PATH including 
rem 	the subdirs.
rem 
rem 	Version: 2.2
rem
echo ##############################################
pause


:BEGIN
echo.
echo ################   Start...    ################ 
goto MAIN


:MAIN
rem search all the apks in the PATH.
rem ������������Ҫ��װ��apk�ļ����ڵ�·��,
rem ������Զ��������ļ���(������Ŀ¼)�µ����е�apk�ļ���
set work_path=F:\Android\MyApks 
cd /d %work_path% 

for /R %%s in (*.apk) do (
echo Install the %%s 
adb install -r "%%s"
)


:End
echo.
echo ################  Completed!   ################
pause
