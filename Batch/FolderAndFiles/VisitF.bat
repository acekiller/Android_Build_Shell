@echo off 
title VisitF.bat

:: VisitF.bat - 对指定路径指定文件进行遍历的程序 
:: 第一参数为要遍历的文件（支持通配符），第二参数为要遍历的路径（缺省为C盘根）

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
