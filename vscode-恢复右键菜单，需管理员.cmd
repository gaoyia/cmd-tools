@echo off
setlocal EnableDelayedExpansion

::----------------------------------------------------------
:: 函数：探测 VSCode 安装路径
::----------------------------------------------------------
:DetectVSCode
REM 1) 从注册表卸载信息里找
for /f "tokens=2*" %%A in (
  'reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "DisplayName" 2^>nul ^| findstr /I "Visual Studio Code"') do (
  for /f "tokens=2*" %%K in (
    'reg query "%%A\%%B\.." /v "InstallLocation" 2^>nul') do (
    if exist "%%L\Code.exe" set "DETECTED=%%L\Code.exe" & goto :Found
  )
)

REM 2) 用 where 命令
for /f "delims=" %%P in ('where Code.exe 2^>nul') do (
  set "DETECTED=%%~dpP"
  set "DETECTED=!DETECTED:~0,-1!\Code.exe"
  goto :Found
)

REM 3) 默认用户安装目录
set "DETECTED=%localappdata%\Programs\Microsoft VS Code\Code.exe"
if exist "%DETECTED%" goto :Found

set "DETECTED="

:Found
::----------------------------------------------------------
:: 2. 如果探测不到或用户想改，允许手输
::----------------------------------------------------------
if defined DETECTED (
  echo 已检测到 VSCode：
  echo   %DETECTED%
  echo.
  set /p "CONFIRM=回车直接采用，或输入新的路径："
  if not "!CONFIRM!"=="" set "DETECTED=!CONFIRM!"
) else (
  echo 未检测到 VSCode 安装路径。
  set /p "DETECTED=请输入 VSCode 的完整路径（含 Code.exe）："
)

::----------------------------------------------------------
:: 3. 路径校验
::----------------------------------------------------------
if not exist "%DETECTED%" (
  echo 路径无效：%DETECTED%
  pause & exit /b 1
)

::----------------------------------------------------------
:: 4. 写入注册表三连
::----------------------------------------------------------
echo 正在写入注册表...

REM 文件
reg add "HKEY_CLASSES_ROOT\*\shell\VSCode"         /ve /t REG_SZ /d "用 VSCode 打开"       /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\VSCode"         /v  Icon /t REG_SZ /d "\"%DETECTED%\""   /f >nul
reg add "HKEY_CLASSES_ROOT\*\shell\VSCode\command" /ve /t REG_SZ /d "\"%DETECTED%\" \"%%1\"" /f >nul

REM 文件夹图标
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode"         /ve /t REG_SZ /d "用 VSCode 打开文件夹" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode"         /v  Icon /t REG_SZ /d "\"%DETECTED%\""   /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\shell\VSCode\command" /ve /t REG_SZ /d "\"%DETECTED%\" \"%%V\"" /f >nul

REM 文件夹空白处
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode"         /ve /t REG_SZ /d "用 VSCode 打开" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode"         /v  Icon /t REG_SZ /d "\"%DETECTED%\"" /f >nul
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode\command" /ve /t REG_SZ /d "\"%DETECTED%\" \"%%V\"" /f >nul

echo 完成！路径已设为 %DETECTED%
pause
