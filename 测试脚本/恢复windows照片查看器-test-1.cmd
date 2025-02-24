chcp 65001
@echo off
setlocal enabledelayedexpansion

echo 正在恢复Windows照片查看器关联...

echo 需要管理员权限，请右键以管理员身份运行

:: 第一部分：HKEY_CLASSES_ROOT 相关键值
reg add "HKCR\Applications\photoviewer.dll\shell\open" /v "MuiVerb" /t REG_SZ /d "@photoviewer.dll,-3043" /f

reg add "HKCR\Applications\photoviewer.dll\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f

reg add "HKCR\Applications\photoviewer.dll\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f

:: 处理图片类型关联
set "extensions=Bitmap JFIF Jpeg Gif Png Wdp"
for %%e in (%extensions%) do (
    reg add "HKCR\PhotoViewer.FileAssoc.%%e" /v "ImageOptionFlags" /t REG_DWORD /d 1 /f
    reg add "HKCR\PhotoViewer.FileAssoc.%%e\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\imageres.dll,-70" /f
    reg add "HKCR\PhotoViewer.FileAssoc.%%e\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f
)

:: 特殊处理不同文件类型的差异
reg add "HKCR\PhotoViewer.FileAssoc.JFIF\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\imageres.dll,-72" /f
reg add "HKCR\PhotoViewer.FileAssoc.Gif\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\imageres.dll,-83" /f
reg add "HKCR\PhotoViewer.FileAssoc.Png\DefaultIcon" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\imageres.dll,-71" /f

:: 第二部分：HKEY_LOCAL_MACHINE 注册
reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationDescription" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3069" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities" /v "ApplicationName" /t REG_EXPAND_SZ /d "@%%ProgramFiles%%\Windows Photo Viewer\photoviewer.dll,-3009" /f

:: 文件关联映射
set "associations=.jpg=PhotoViewer.FileAssoc.Jpeg .wdp=PhotoViewer.FileAssoc.Wdp .jfif=PhotoViewer.FileAssoc.JFIF .dib=PhotoViewer.FileAssoc.Bitmap .png=PhotoViewer.FileAssoc.Png .jxr=PhotoViewer.FileAssoc.Wdp .bmp=PhotoViewer.FileAssoc.Bitmap .jpe=PhotoViewer.FileAssoc.Jpeg .jpeg=PhotoViewer.FileAssoc.Jpeg .gif=PhotoViewer.FileAssoc.Gif .tif=PhotoViewer.FileAssoc.Tiff .tiff=PhotoViewer.FileAssoc.Tiff"

for %%a in (%associations%) do (
    for /f "tokens=1,2 delims==" %%i in ("%%a") do (
        reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v "%%i" /t REG_SZ /d "%%j" /f
    )
)

echo 注册表项已成功添加

echo 正在刷新系统关联...

for %%f in (.jpg .jpeg .jpe .png .gif .bmp .tif .tiff .dib .jfif .wdp .jxr) do (
    echo 正在关联 %%f 文件类型...
    assoc %%f=PhotoViewer.FileAssoc.%%~xf >nul 2>&1
    ftype PhotoViewer.FileAssoc.%%~xf="%%SystemRoot%%\System32\rundll32.exe" "%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %%1 >nul 2>&1
)

echo 操作完成！请右键图片选择"打开方式"进行设置

:: 在脚本末尾添加验证
echo 验证关联结果：

reg query "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /s

echo.

echo 当前图片关联状态：

assoc | findstr /i ".jpg .jpeg .png .gif .bmp .tif"

goto RestartExplorer

pause


:RestartExplorer

echo 正在重启文件资源管理器...

taskkill /f /im explorer.exe >nul

start explorer.exe

echo 资源管理器已重启！

pause