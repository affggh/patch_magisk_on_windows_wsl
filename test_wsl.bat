@echo off
wsl bash --version 
if not "%errorlevel%"=="0" ( color 4f
echo wsl������ܲ�����
) else (
color af
echo wsl�������...
)
echo.
echo.
pause
echo.
copy "tools\magiskboot" "magiskboot"
wsl ./magiskboot cleanup 2>nul 1>nul
if not "%errorlevel%"=="0" ( color 4f
echo magiskboot������ʹ��
) else (
color af
echo magiskboot����ʹ��
)
del /q "magiskboot"
pause