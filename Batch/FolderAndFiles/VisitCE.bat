:: VisitCE.bat - �ļ����������������������ǿ�� 
:: Will Sort - 10/17/2004 - V2CE 
:: 
:: ������;�� 
:: ��ָ��·��/�ļ��б��µ�ָ���ļ�/Ŀ¼��ִ��ָ������ 
:: 
:: ������˵���� 
:: 1. VISIT [·��1 ·��2...] [����1 ����2...] [�ļ���1 �ļ���2...] 
:: �� [·��] �� [����] �޶��µ� [�ļ���] ִ��ָ������ 
:: 2. VISIT @ �ļ��б�1 [�ļ��б�2...] 
:: ��ָ�� [�ļ��б�] �е��ļ�ִ��ָ������ 
:: 
:: ע����� 
:: - [·��] [����] [�ļ���] ���ɲ�ѡ���ѡ 
:: - [·��] �в��ɰ���ͨ�����[�ļ���] �пɰ�����Ч·����ͨ��� 
:: - [·��] ȱʡΪ��ǰ·����[�ļ���] ȱʡΪ *.* �����������ļ��� 
:: - [·��] [�ļ���] ���ո�ʱ����˫�������� 
:: - [����] ֧�ֵ�DIR����: /S /A /O /L�Ȳ��� /B ��ͻ�� 
:: - [����] ��֧�ֵ�DIR����: /W /P /V ���� /B ��ͻ�� 
:: - [����] �ɵ�����Ԥ��д�� visitcmd.bat �� 
:: - [����] ��ʹ�� %VisitFile% ���ñ����ļ� 
:: - �������� [�ļ��б�] �Ƿ���ڣ�����������Ƿ���Ч 
:: - ����������/ϵͳĿ¼�µ�Ŀ¼���ļ�������������ָ��ʱ���⣩ 
:: 
:: �÷�ʾ���� 
:: visit c:\ /ad /s ����C������Ŀ¼������������Ŀ¼ 
:: visit "C:\My document" /a-d ����"C:\My document"�������ļ� 
:: visit c:\ d:\ e:\ /s /a /on ����C,D,E�������ļ��������ļ������� 
:: visit \ /a ������ǰ�̸�Ŀ�������ļ���Ŀ¼ 
:: �ڱ���δ��ʽָ��������/ϵͳĿ¼ʱ��������"attrib �ļ��� /s"���� 
:: �ļ��б�Ȼ����visitcmd.bat�Ĵ���������%VisitFile%���������Ĵ��� 
:: ��ʹ���ļ��б���б��� 
:: 
:: ���Ա��棺 
:: �� Win98 �����з�ʽ�����޺������ͨ�� 
:: ������Ȼ������ƿ�� 
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
