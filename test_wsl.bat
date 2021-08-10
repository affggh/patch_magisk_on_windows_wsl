@echo off
wsl bash --version 
if not "%errorlevel%"=="0" ( color 4f
echo wsl命令可能不存在
) else (
color af
echo wsl命令存在...
)
echo.
echo.
pause
echo.
copy "tools\magiskboot" "magiskboot"
wsl ./magiskboot cleanup 2>nul 1>nul
if not "%errorlevel%"=="0" ( color 4f
echo magiskboot不可以使用
) else (
color af
echo magiskboot可以使用
)
del /q "magiskboot"
pause