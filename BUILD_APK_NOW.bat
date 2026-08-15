@echo off
setlocal EnableExtensions
cd /d "%~dp0"
color 0A
cls
echo ===============================================================
echo   LAFA POULTRY MANAGER v2.0 - ONE CLICK APK BUILDER
echo ===============================================================
echo.
where flutter >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Flutter haipo kwenye PATH.
  echo Tumia GitHub Actions kama huna computer/Flutter.
  pause
  exit /b 1
)
if not exist android\gradlew.bat (
  echo [1/5] Creating Android project files...
  flutter create --platforms=android --org com.lafasoftware --project-name lafa_poultry_manager .
  if errorlevel 1 goto :failed
)
echo [2/5] Configuring Android...
python scripts\patch_android.py
if errorlevel 1 goto :failed
echo [3/5] Getting packages...
call flutter pub get
if errorlevel 1 goto :failed
echo [4/5] Building release APK...
call flutter build apk --release
if errorlevel 1 goto :failed
echo [5/5] Copying APK...
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "LAFA-Poultry-Manager-v2.apk" >nul
echo.
echo [SUCCESS] %CD%\LAFA-Poultry-Manager-v2.apk
pause
exit /b 0
:failed
echo [FAILED] Build imepata error.
pause
exit /b 1
