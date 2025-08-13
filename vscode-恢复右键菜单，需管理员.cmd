@echo off
setlocal EnableDelayedExpansion

::----------------------------------------------------------
:: ������̽�� VSCode ��װ·��
::----------------------------------------------------------
:DetectVSCode
REM 1) ��ע���ж����Ϣ����
for /f "tokens=2*" %%A in (
  'reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "DisplayName" 2^>nul ^| findstr /I "Visual Studio Code"') do (
  for /f "tokens=2*" %%K in (
    'reg query "%%A\%%B\.." /v "InstallLocation" 2^>nul') do (
    if exist "%%L\Code.exe" set "DETECTED=%%L\Code.exe" & goto :Found
  )
)

REM 2) �� where ����
for /f "delims=" %%P in ('where Code.exe 2^>nul') do (
  set "DETECTED=%%~dpP"
  set "DETECTED=!DETECTED:~0,-1!\Code.exe"
  goto :Found
)

REM 3) Ĭ���û���װĿ¼
set "DETECTED=%localappdata%\Programs\Microsoft VS Code\Code.exe"
if exist "%DETECTED%" goto :Found

set "DETECTED="

:Found
::----------------------------------------------------------
:: 2. ���̽�ⲻ�����û���ģ���������
::----------------------------------------------------------
if defined DETECTED (
  echo �Ѽ�⵽ VSCode��
  echo   %DETECTED%
  echo.
  set /p "CONFIRM=�س�ֱ�Ӳ��ã��������µ�·����"
  if not "!CONFIRM!"=="" set "DETECTED=!CONFIRM!"
) else (
  echo δ��⵽ VSCode ��װ·����
  set /p "DETECTED=������ VSCode ������·������ Code.exe����"
)

::----------------------------------------------------------
:: 3. ·��У��
::----------------------------------------------------------
if not exist "%DETECTED%" (
  echo ·����Ч��%DETECTED%
  pause & exit /b 1
)

::----------------------------------------------------------
:: 4. д��ע�������
::----------------------------------------------------------
echo ����д��ע���...

REM �ļ�
reg add "HKEY_CLASSES_ROOT\*\shell\VSCode"         /ve /t REG_SZ /d "�� VSCode ��"       /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\VSCode"         /v  Icon /t REG_SZ /d "\"%DETECTED%\""   /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\VSCode\command" /ve /t REG_SZ /d "\"%DETECTED%\" \"%%1\"" /f >nul

REM �ļ���ͼ��
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode"         /ve /t REG_SZ /d "�� VSCode ���ļ���" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode"         /v  Icon /t REG_SZ /d "\"%DETECTED%\""   /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode\command" /ve /t REG_SZ /d "\"%DETECTED%\" \"%%V\"" /f >nul

REM �ļ��пհ״�
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode"         /ve /t REG_SZ /d "�� VSCode ��" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode"         /v  Icon /t REG_SZ /d "\"%DETECTED%\"" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode\command" /ve /t REG_SZ /d "\"%DETECTED%\" \"%%V\"" /f >nul

echo ��ɣ�·������Ϊ %DETECTED%
pause
