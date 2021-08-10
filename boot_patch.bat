:: Copyright by affggh from coolapk
:: If you want change this 
:: You can just add my qq 879632264
@echo off
setlocal enabledelayedexpansion
color 0f
cd %~dp0
set "Path=%Path%;%~dp0tools\Java\jdk-16.0.1\bin"
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
set bootimg="%1"
if /I "%1"=="--help" call :usage&pause&exit /b 0

echo %bootimg%

if not exist "%bootimg%" echo     - 你没有选择boot镜像文件...&call :usage&pause&exit /b 1

if exist "%boogimg%" title 你选择的boot文件为...%bootimg%...

goto :PATCH
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
:get_config
for /f %%i in ('!adb! get-state') do set state=%%i
if /I "!state!"=="device" (
    if exist "config.txt" del /q "config.txt"
	echo     - 检测到连接到了安卓设备...
	echo     - 正在从设备中获取配置信息...
	for /F %%i in ('!adb! shell getprop ro.product.cpu.abi') do (
		set abi=%%i
		if /I "!abi:~0,5!"=="arm64" (
		set "ARCH=arm64"
		set "ARCH32=arm"
		set "IS64BIT=true"
	)
	if /I "!abi:~0,7!"=="armeabi" (
		set "ARCH=arm"
		set "ARCH32=arm"
		set "IS64BIT=false"
	)
	if /I "!abi:~0,3!"=="x86" (
		set "ARCH=x86"
		set "ARCH32=x86"
		set "IS64BIT=false"
	)
	if /I "!abi:~0,6!"=="x86_64" (
		set "ARCH=x64"
		set "ARCH32=x86"
		set "IS64BIT=true"
	)
	)
	for /F %%i in ('!adb! shell getprop ro.build.system_root_image') do set sar=%%i
	if "!sar!"=="true" ( set "KEEPVERITY=true"
	) else (
		set "KEEPVERITY=false"
	) 
	for /F %%i in ('!adb! shell getprop ro.crypto.state') do set encrypt=%%i
	if "!encrypt!"=="unencrypted" ( set "KEEPFORCEENCRYPT=false"
	) else (
		set "KEEPFORCEENCRYPT=true"
	) 
	echo     - 检测信息完整程度...
	for /F %%i in ('type config.txt ^| findstr /v "#"') do set %%i
		if not defined ARCH echo     - 错误，配置错误，请自行输入配置信息...&pause&call :make_config
		if not defined ARCH32 echo     - 错误，配置错误，请自行输入配置信息...&pause&call :make_config
		if not defined IS64BIT echo     - 错误，配置错误，请自行输入配置信息...&pause&call :make_config
		if not defined KEEPVERITY echo     - 错误，配置错误，请自行输入配置信息...&pause&call :make_config
		if not defined KEEPFORCEENCRYPT echo     - 错误，配置错误，请自行输入配置信息...&pause&call :make_config
	) else (
		echo     - 没有检测到设备，将选用手动配置...
		call :make_config
		notepad config.txt
		
		for /f %%i in ('type config.txt ^| findstr /v "#"') do set %%i
)
goto :eof
:make_config
echo # ARCH include arm64/arm/x86_64/x86>config.txt
echo # ARCH 包含四个选项 arm64/arm/x86_64/x86>>config.txt
if defined ARCH ( echo "ARCH=!ARCH!">>config.txt
) else (
echo "ARCH=">>config.txt
)
echo.>>config.txt
echo # ARCH32 include arm/x86>>config.txt
echo # ARCH32 包含两个选项 arm/x86>>config.txt
if defined ARCH32 ( echo "ARCH32=!ARCH32!">>config.txt
) else (
echo "ARCH32=">>config.txt
)
echo.>>config.txt
echo # This selection need rely on ARCH selection,if ARCH is arm64 or x86_64 swich this to true>>config.txt
echo # 这个选项依赖于ARCH这个选项，如果ARCH是arm64或者x86_64这两者，将这个选项设置为true>>config.txt
if defined IS64BIT ( echo "IS64BIT=!IS64BIT!">>config.txt
) else (
echo "IS64BIT=true/false">>config.txt
)
echo.>>config.txt
echo # As you can see,this is keep verity>>config.txt
echo # 一目了然，这是保持验证...>>config.txt
if defined KEEPVERITY ( echo "KEEPVERITY=!KEEPVERITY!">>config.txt
) else (
echo "KEEPVERITY=true/false">>config.txt
)
echo.>>config.txt
echo # As you can see,this is keep force encrypt...>>config.txt
echo # 一目了然，这是保持强制加密...>>config.txt
if defined KEEPFORCEENCRYPT ( echo "KEEPFORCEENCRYPT=!KEEPFORCEENCRYPT!">>config.txt
) else (
echo "KEEPFORCEENCRYPT=true/false">>config.txt
)
echo.>>config.txt
echo # RECOVERYMODE default is false,shell script can detect it automaticlly>>config.txt
echo # RECOVERYMODE 默认是处于fasle选项的，shell脚本可以自动的检测这个选项，除非某些特殊必要，否则无需修改此选项...>>config.txt
if defined RECOVERYMODE ( echo "RECOVERYMODE=!RECOVERYMODE!">>config.txt
) else (
echo "RECOVERYMODE=false">>config.txt
)
echo.>>config.txt
echo # This Selection is for AVB1.0 signer and default if fasle>>config.txt
echo # If you in some reason need to sign boot image swich this to true>>config.txt
echo # 这个选项是给avb1.0工具自动签名用的，默认是fasle选项的>>config.txt
echo # 如果你有某些奇怪的原因需要用avb1.0给boot签名，你可以修改此选项为true...>>config.txt
if defined SIGNBOOT_WITH_AVB1.0 ( echo "SIGNBOOT_WITH_AVB1.0=!SIGNBOOT_WITH_AVB1.0!">>config.txt
) else (
echo "SIGNBOOT_WITH_AVB1.0=false">>config.txt
)
goto :eof
:PATCH
if not exist config.txt ( call :get_config
) else (
for /f %%i in ('type config.txt ^| findstr /v "#"') do set %%i
)
if not defined SIGNBOOT_WITH_AVB1.0 (
call :error 检测到签名的选项未定义...
call :print 请定义是否使用avb1.0签名工具签名boot...
set /p input=[true/false]--^>
set "SIGNBOOT_WITH_AVB1.0=!input!"
)
if not exist tmp\ md tmp\
type tools\func.sh>tmp\patch.sh
:: FLAGS
if defined ARCH echo ARCH=!ARCH!>>patch.sh
if defined ARCH32 echo ARCH32=!ARCH32!>>patch.sh
if defined IS64BIT echo IS64BIT=!IS64BIT!>>patch.sh
if /I "!KEEPVERITY!"=="true" (
echo KEEPVERITY=true>>tmp\patch.sh
) else (
echo KEEPVERITY=false>>tmp\patch.sh
)
if /I "!KEEPFORCEENCRYPT!"=="true" (
echo KEEPFORCEENCRYPT=true>>tmp\patch.sh
) else (
echo KEEPFORCEENCRYPT=false>>tmp\patch.sh
)
if /I "!RECOVERYMODE!"=="true" (
echo RECOVERYMODE=true>>tmp\patch.sh
) else (
echo RECOVERMODE=false>>tmp\patch.sh
)
echo export KEEPVERITY>>tmp\patch.sh
echo export KEEPFORCEENCRYPT>>tmp\patch.sh
:: END FLAGS
type tools\patch.sh>>tmp\patch.sh
copy tmp\patch.sh patch.sh
:: fix wsl sh cant read error
!dos2unix! patch.sh
::
call :print 复制文件...
copy !bootimg! stock-boot.img

if /I "!ARCH!"=="arm64" (
copy "build\arm64-v8a\libmagisk64.so" "magisk64"
copy "build\arm64-v8a\libmagiskinit.so" "magiskinit"
)
if /I "!ARCH!"=="arm" (
copy "build\armeabi-v7a\libmagisk32.so" "magisk32"
copy "build\armeabi-v7a\libmagiskinit.so" "magiskinit"
)
if /I "!ARCH!"=="x86_64" (
copy "build\x86_64\libmagisk64.so" "magisk64"
copy "build\x86_64\libmagiskinit.so" "magiskinit"
)
if /I "!ARCH!"=="x86" (
copy "build\x86\libmagisk32.so" "magisk32"
copy "build\x86\libmagiskinit.so" "magiskinit"
)

copy "tools\magiskboot" "magiskboot"

wsl sh patch.sh stock-boot.img

:: Clean up
wsl ./magiskboot cleanup 1>nul 2>nul
if exist "new-boot.img" (
call :print 检测到文件生成...
echo     - 正在检测修补情况...
wsl ./magiskboot unpack new-boot.img 1>nul 2>nul
wsl ./magiskboot cpio ramdisk.cpio test 1>nul 2>nul
if "!errorlevel!"=="1" ( call :print 检测到magisk对boot的修补...
) else (
call :error 未检测到magisk对boot的修补...可能失败了...
)
)
wsl ./magiskboot cleanup 1>nul 2>nul
if exist "magisk32" del /q "magisk32"
if exist "magisk64" del /q "magisk64"
if exist "magiskinit" del /q "magiskinit"
if exist "magiskboot" del /q "magiskboot"
if exist "tmp\" rd /s /q "tmp\"
if exist "patch.sh" del /q "patch.sh"

call :print 正在检测原boot文件的签名修补情况...
for /f "tokens=2 delims=," %%i in ('!verify_signature! --file "stock-boot.img" ^| findstr "yay"') do set "signature=%%i"
if defined signature set "signature=true"
if /I "!signature!"=="true" (
call :print 检测到了谷歌测试密钥，avb1.0，准备使用boot_signer.jar进行签名...
where java > nul
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