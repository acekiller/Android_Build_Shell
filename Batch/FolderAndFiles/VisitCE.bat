:: VisitCE.bat - 文件遍历批处理程序命令行增强版 
:: Will Sort - 10/17/2004 - V2CE 
:: 
:: 程序用途： 
:: 对指定路径/文件列表下的指定文件/目录集执行指定操作 
:: 
:: 命令行说明： 
:: 1. VISIT [路径1 路径2...] [开关1 开关2...] [文件集1 文件集2...] 
:: 对 [路径] 和 [开关] 限定下的 [文件集] 执行指定操作 
:: 2. VISIT @ 文件列表1 [文件列表2...] 
:: 对指定 [文件列表] 中的文件执行指定操作 
:: 
:: 注意事项： 
:: - [路径] [参数] [文件集] 均可不选或多选 
:: - [路径] 中不可包含通配符，[文件集] 中可包含有效路径和通配符 
:: - [路径] 缺省为当前路径，[文件集] 缺省为 *.* （并非所有文件） 
:: - [路径] [文件集] 含空格时需用双引号引起 
:: - [参数] 支持的DIR开关: /S /A /O /L等不与 /B 冲突者 
:: - [参数] 不支持的DIR开关: /W /P /V 等与 /B 冲突者 
:: - [操作] 由调用者预先写入 visitcmd.bat 中 
:: - [操作] 中使用 %VisitFile% 引用遍历文件 
:: - 程序检查检查 [文件列表] 是否存在，但不检查它是否有效 
:: - 不遍历隐藏/系统目录下的目录和文件（在命令行中指定时例外） 
:: 
:: 用法示例： 
:: visit c:\ /ad /s 遍历C盘所有目录，包含所有子目录 
:: visit "C:\My document" /a-d 遍历"C:\My document"下所有文件 
:: visit c:\ d:\ e:\ /s /a /on 遍历C,D,E中所有文件，并按文件名排序 
:: visit \ /a 遍历当前盘根目下所有文件和目录 
:: 在遍历未显式指定的隐藏/系统目录时，可以用"attrib 文件集 /s"生成 
:: 文件列表，然后在visitcmd.bat的代码中引用%VisitFile%第三至最后的串， 
:: 再使用文件列表进行遍历 
:: 
:: 测试报告： 
:: 在 Win98 命令行方式下有限黑箱测试通过 
:: 性能仍然是最大的瓶颈 
:: 
@echo off 
if "%1"=="$" goto MakeList 
if "%1"=="@" goto CopyList 
if "%1"=="" goto End 
set VisitCommand=%0 
:GetArgu 

:GetPath 
if not exist %1.\nul goto GetSwitch 
set VisitPath=%VisitPath% %1 
goto GetNext 

:GetSwitch 
echo %1 | find "/" > nul 
if errorlevel 1 goto GetFilter 
set VisitSwitch=%VisitSwitch% %1 
goto GetNext 

:GetFilter 
echo %1 | find "*" > nul 
if not errorlevel 1 goto SetFilter 
echo %1 | find "?" > nul 
if errorlevel 1 goto End 

:SetFilter 
set VisitFilter=%VisitFilter% %1 

:GetNext 
shift 
if not [%1]==[] goto GetArgu 
%VisitCommand% $ %VisitFilter% 

:MakeList 
if not [%VisitPath%]==[] goto ForMake 

:DirMake 
dir %2 /b %VisitSwitch% >> ~ 
goto MakeNext
 
:ForMake 
for %%p in (%VisitPath%) do dir %%p.\%2 /b %VisitSwitch% >> ~ 

:MakeNext 
shift 
if not [%2]==[] goto MakeList 
find "~" /v < ~ > ~ 
if not errorlevel 1 copy ~ ~>nul 
goto MakePreLine 

:CopyList 
if not [%2]==[] if exist %2 type %2>>~ 
shift 
if not [%2]==[] goto CopyList 

:MakePreLine 
if not exist ~ goto End 
echo set VisitFile=> ~ 
for %%c in (rcx e w q) do echo %%c>> ~ 
debug ~ < ~ > nul 
if [%OS%]==[Windows_NT] chcp 936 > nul 

:LoopVisit 
copy ~+~ ~ > nul 
find "set VisitFile=" < ~ > ~visit.bat 
call ~visit.bat 
if "%VisitFile%"=="" goto Clear 
if not exist visitcmd.bat echo Visiting %VisitPath% %VisitSwitch% %VisitFilter% - %VisitFile% 
if exist visitcmd.bat call visitcmd.bat 
find "set VisitFile=" /v < ~ > ~ 
goto LoopVisit 

:Clear 
for %%f in (~visit.*) do del %%f 
for %%e in (Command Path Switch Filter File) do set Visit%%e= 

:End 
