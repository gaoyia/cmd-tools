chcp 65001
@echo off
cls
echo PowerShell执行策略切换器
echo --------------------------
echo 当前策略: 
powershell -Command "Get-ExecutionPolicy | Write-Host -ForegroundColor Cyan"

:menu
echo.

echo 可选操作:

echo 1) 设置为 RemoteSigned-允许本地脚本

echo 2) 设置为 Bypass-临时绕过策略

echo 3) 设置为 Unrestricted-完全解除限制

echo 4) 恢复默认 Restricted

echo 5) 仅查看当前策略

echo 6) 退出

echo.

set /p choice=请输入选项数字: 
set "choice=%choice:"=%"
set "choice=%choice:~0,1%"

echo  %choice%
if "%choice%"=="1" goto set_remote
if "%choice%"=="2" goto set_bypass
if "%choice%"=="3" goto set_unrestricted
if "%choice%"=="4" goto set_restricted
if "%choice%"=="5" goto show_policy
:: 优化退出方式（避免残留进程）
if "%choice%"=="0" (
    exit /b 0
) else (
    cls
    echo 无效输入，请重新选择
    timeout /t 1 >nul
    goto menu
)

:set_remote
echo 正在设置 RemoteSigned...
powershell -Command "Start-Process cmd -ArgumentList '/c powershell -Command Set-ExecutionPolicy RemoteSigned -Force' -Verb RunAs"
goto show_result

:set_bypass
echo 正在设置 Bypass...
powershell -Command "Start-Process cmd -ArgumentList '/c powershell -Command Set-ExecutionPolicy Bypass -Force' -Verb RunAs"
goto show_result

:set_unrestricted
echo 正在设置 Unrestricted...
powershell -Command "Start-Process cmd -ArgumentList '/c powershell -Command Set-ExecutionPolicy Unrestricted -Force' -Verb RunAs"
goto show_result

:set_restricted
echo 正在恢复 Restricted...
powershell -Command "Start-Process cmd -ArgumentList '/c powershell -Command Set-ExecutionPolicy Restricted -Force' -Verb RunAs"
goto show_result

:show_policy
powershell -Command "Get-ExecutionPolicy | Write-Host -ForegroundColor Yellow"
goto menu

:show_result
echo 操作已完成，当前策略:
powershell -Command "Get-ExecutionPolicy | Write-Host -ForegroundColor Green"
timeout /t 2 >nul
goto menu

:to_exit
echo 退出中...
timeout /t 1 >nul
exit
