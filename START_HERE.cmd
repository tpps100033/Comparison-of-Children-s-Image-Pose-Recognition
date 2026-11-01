@echo off
setlocal
echo Downloading the current research package into Ubuntu on WSL2 and starting it...
wsl.exe -- bash -lc "set -Eeuo pipefail; if ! command -v curl >/dev/null; then sudo apt-get update && sudo apt-get install -y curl; fi; mkdir -p ~/children-pose-paper; cd ~/children-pose-paper; curl -fsSL https://github.com/tpps100033/Comparison-of-Children-s-Image-Pose-Recognition/archive/refs/heads/main.tar.gz | tar -xz --strip-components=1; bash START_HERE.sh"
set "RESULT=%ERRORLEVEL%"
if not "%RESULT%"=="0" echo The run stopped with exit code %RESULT%. Review the Ubuntu output above.
echo.
pause
exit /b %RESULT%
