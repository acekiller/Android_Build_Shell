@echo off 
title VisitF.bat

:: VisitF.bat - ��ָ��·��ָ���ļ����б����ĳ��� 
:: ��һ����ΪҪ�������ļ���֧��ͨ��������ڶ�����ΪҪ������·����ȱʡΪC�̸���

:main 
if [%1]==[] if not exist goto end1 

:init 
if exist if exist goto loop 
set file=%1 
set base=%2 
if [%2]==[] set base=c: 
dir %base%\%file% /s /a /b > 
echo e 100 ''set file='' > 
echo w >> 
echo q >> 

:loop 
fc nul /n | find " 1:" > setfile.bat 
if errorlevel 1 goto restore 
debug setfile.bat nul 
call setfile.bat 
echo Visiting the file: %file% 
:: User specified visit code replace this line 
find "%file%" /v 
copy > nul 
goto loop 

:restore 
if exist del 
if exist del 
if exist del 
if exist setfile.bat del setfile.bat 

:end1
echo. 
pause
