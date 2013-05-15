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
echo ################   开始...    ################ 
goto MAIN


:MAIN
rem search all the apks in the PATH.
rem 首先请设置需要安装的apk文件所在的路径,
rem 程序会自动搜索该文件夹(包括子目录)下的所有的apk文件，

for /R %%s in (*.apk) do (
echo 正在安装 %%s 
adb install -r "%%s"
)


:End
echo.
echo ################  全部apk文件已安装!   ################
pause
