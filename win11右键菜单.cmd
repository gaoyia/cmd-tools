@echo off
chcp 65001 > nul

title win11右键菜单 - 经典右键菜单 ———— 切换工具

:MainMenu
cls

echo win11右键菜单 - 经典右键菜单

echo 切换工具 (重启文件资源管理器生效)

echo ---------------------------

echo 请选择操作模式：

echo 1. 切换为经典右键菜单

echo 2. 恢复Win11默认菜单

echo 3. 重启文件资源管理器

echo 4. 退出程序

choice /c 1234 /n /m "请输入选项（1-4）:"

if errorlevel 4 exit /b
if errorlevel 3 goto RestartExplorer
if errorlevel 2 goto DefaultMenu
if errorlevel 1 goto ClassicMenu

:ClassicMenu
echo 正在切换为经典右键菜单...
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
goto Finish

:DefaultMenu
echo 正在恢复Win11默认菜单...
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
goto Finish

:RestartExplorer
echo 正在重启文件资源管理器...
taskkill /f /im explorer.exe >nul
start explorer.exe
echo 资源管理器已重启！
goto Finish

:Finish
echo.
echo 操作已完成，3秒后返回主菜单...
timeout /t 3 /nobreak >nul
goto MainMenu