@echo off
cd /d %~dp0
echo.

if "%~3" neq "" (
  echo Embedding XML manifest... Done!
  ResHacker -addoverwrite %1, %1, "%~3", 24,1,1033
  del "%~3"
)

call %2.bat %1