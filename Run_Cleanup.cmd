@echo off
Title VM Dynamic Disk Cleanup Setup

:: Check for Administrator privileges by trying to access a restricted system command
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting Administrative privileges...
    :: Relaunch this batch script as Administrator
    PowerShell -NoProfile -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /B
)

:: If we reach here, we are running as Admin.
:: Change the working directory to the folder where this batch file is located
cd /d "%~dp0"

echo ===================================================
echo Administrator privileges confirmed.
echo Starting VM Cleanup and Space Reclaim Script...
echo ===================================================
echo.

:: Run the PowerShell script and temporarily bypass execution policy restrictions
PowerShell -NoProfile -ExecutionPolicy Bypass -File "Cleanup_VM.ps1"

echo.
echo Script execution finished. You can now compact the virtual disk from your Host machine.
pause