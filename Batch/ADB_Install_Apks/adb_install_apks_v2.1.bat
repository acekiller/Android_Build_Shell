@echo off 
title ADB install apks[By LongLuo]
goto BEGIN

:COMMENT
echo ##############################################
rem 	File.bat
rem 	 Copyright (c) long.luo. All Rights Reserved. 
rem 		
rem 	Description:
rem 		for usage.
rem 
rem 	Version: 2.1
rem
echo ##############################################
pause


:BEGIN
echo ##############################################
echo  begin...
goto MAIN

:TEST
:: 判断输入路径是不是文件夹
set /p input=请输入要进行判断的路径：
@echo 你输入的文件夹："%input%"
cd /d "%input%"
set cur_dir=%cd%*.rmvb
for %%i in (%cur_dir%) do echo %%i
pause 


rem set work_path=Z:\work\test
rem Z: 
rem cd %work_path% 
rem for /R %%s in (.) do ( 
rem echo %%s 
rem ) 


:MAIN
set work_path=F:\Android\MyApks 
cd /d %work_path% 
for /R %%s in (*) do ( 
if 
echo Install the %%s 
rem adb install -r "%%s"
) 

:END
echo.
pause 
