:: Copyright by affggh from coolapk
:: If you want change this 
:: You can just add my qq 879632264
@echo off
setlocal enabledelayedexpansion
color 0f
cd %~dp0
:: Add tools for next action
if not defined cecho set "cecho=%~dp0tools\cecho.exe"
::if not defined busybox set "busybox=%~dp0tools\busybox\busybox.exe"
if not defined magiskboot set "magiskboot=%~dp0tools\flinux\flinux.exe %~dp0tools\flinux\magiskboot"
if not defined adb set "adb=%~dp0tools\platform-tools\adb.exe"
:: Add this tool to convert \n to \r
if not defined dos2unix set "dos2unix=%~dp0tools\dos2unix\dos2unix.exe"
:: Add verify_signature command
if not defined verify_signature set "verify_signature=%~dp0tools\dump_avb_signature\verify_signature.exe"
:: set boot.img file need to patch

goto :start
:usage
echo     - Usage:
echo             boot_patch.bat ^< boot.img ^>
echo.
echo             boot_patch.bat --help
echo                           Show this information.
echo             此工具可以自动检测手机并从手机中获取配置，此功能需要usb调试权限...
goto :eof
:print
rem print correct imformation with green color
if not "%1"=="" (
!cecho! {\n}{0a}    [%1]{\n}{0f}
) else (
if "!errorlevel!"=="0" ( echo !cecho! {\n}{0a}    [命令正确执行...]{\n}{0f}
) else (
echo !cecho! {\n}{0c}    [命令执行异常...]{\n}{0f}
)
)
goto :eof
:abort
rem print error imformation with red color and exit
if not "%1"=="" (
!cecho! {\n}{0c}    [%1]{\n}{0f}
)
timeout /t 5 /nobreak > nul
exit /b 1
goto :eof
:error
rem only print error imformation with red color
if not "%1"=="" (
!cecho! {\n}{0c}    [%1]{\n}{0f}
)
timeout /t 3 /nobreak > nul
goto :eof
:start
call :print 正在检测原boot文件的签名修补情况...
for /f "tokens=2 delims=," %%i in ('!verify_signature! --file "stock-boot.img" ^| findstr "yay"') do set "signature=%%i"
if defined signature set "signature=true"
if /I "!signature!"=="true" (
call :print 检测到了谷歌测试密钥，avb1.0，准备使用boot_signer.jar进行签名...
where java
if "!errorlevel!"=="1" (
call :error 错误，java不存在，无法进行签名...
) else (
call :print 准备使用boot_signer.jar命令进行签名...
java -jar "tools\boot_signer\boot_signer.jar" /boot "new-boot.img" "tools\boot_signer\avb\verity.pk8" "tools\boot_signer\avb\verity.x509.pem" "new-boot_signed.img"
)
) else (
if "!SIGNBOOT_WITH_AVB1.0!"=="true" (
call :print 检测到开启了使用avb1.0签名boot的选项，正在签名...
java -jar "tools\boot_signer\boot_signer.jar" /boot "new-boot.img" "tools\boot_signer\avb\verity.pk8" "tools\boot_signer\avb\verity.x509.pem" "new-boot_signed.img"
)
)
pause