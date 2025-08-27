@echo off
title Simple APK Editor

echo.
echo ======================================================
echo           Simple APK Editor (Manual)
echo ======================================================
echo.

:SELECT_APK
set "apk_path="
set /p "apk_path=Drag and drop your APK file here and press ENTER: "
if not exist "%apk_path%" (
    echo.
    echo ERROR: File not found. Please try again.
    echo.
    goto SELECT_APK
)
set "apk_path=%apk_path:"=%"

set "apk_name=%~n1"
set "apk_dir_name=unpacked_%apk_name%"

echo.
echo Unpacking the APK...
java -jar apktool.jar d "%apk_path%" -o "%apk_dir_name%"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to unpack the APK. Make sure APKTool is working.
    echo.
    pause
    exit /b 1
)

echo.
echo ======================================================
echo      APK Unpacked!
echo      The contents are in the folder: "%apk_dir_name%"
echo.
echo      You can now manually edit files (images, audio, etc.)
echo      inside this folder using your preferred applications.
echo      For example:
echo      - To replace an image, find the image in the "res" directory and replace it with a new one of the same name and format.
echo      - To edit text, find XML files in "res" and open them in a text editor.
echo.
echo ======================================================
echo.

pause

echo.
echo Rebuilding the APK...
java -jar apktool.jar b "%apk_dir_name%" -o "rebuilt_%apk_name%.apk"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to rebuild the APK.
    echo.
    pause
    exit /b 1
)

echo.
echo Signing the new APK...
echo.
echo NOTE: A debug keystore is required for signing.
echo       You can generate one with 'keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000'.
echo.
set "new_apk_name=rebuilt_%apk_name%.apk"
set "signed_apk_name=signed_%apk_name%.apk"

if exist debug.keystore (
    apksigner sign --ks debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android --out "%signed_apk_name%" "%new_apk_name%"
) else (
    echo.
    echo WARNING: debug.keystore not found. Signing skipped.
    echo          You will need to manually sign the file "%new_apk_name%"
    echo          using a tool like `apksigner` or `jarsigner` before installing.
)

echo.
echo ======================================================
echo           Task Complete!
echo.
echo A new APK has been created.
echo Unsigned:  %new_apk_name%
if exist signed_apk_name (
    echo Signed:    %signed_apk_name%
)
echo.
echo You can now install the signed APK on your device.
echo ======================================================

echo.
pause