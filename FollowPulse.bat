@echo off
REM FollowPulse - GitHub Relationship Manager
REM -----------------------------------------
REM Choose which script to run

:menu
cls
echo.
echo FollowPulse - GitHub Relationship Manager
echo -----------------------------------------
echo Choose an option:
echo 1. Run FollowPulse.py (Python)
echo 2. Run FollowPulse.ps1 (PowerShell)
echo 3. Run FollowPulse.rb (Ruby)
echo 4. Run FollowPulse.sh (Git Bash / Shell)
echo 5. Exit
echo.

set /p choice=Enter your choice (1-5):

if "%choice%"=="1" (
    echo Running FollowPulse.py...
    echo.
    python "%~dp0FollowPulse.py"
) else if "%choice%"=="2" (
    echo Running FollowPulse.ps1...
    echo.
    powershell -File "%~dp0FollowPulse.ps1"
) else if "%choice%"=="3" (
    echo Running FollowPulse.rb...
    echo.
    ruby "%~dp0FollowPulse.rb"
) else if "%choice%"=="4" (
    echo Running FollowPulse.sh...
    echo.
    "%~dp0FollowPulse.sh"
) else if "%choice%"=="5" (
    exit
) else (
    echo Invalid choice. Please try again.
    timeout /t 3 /nobreak >nul
    goto menu
)
