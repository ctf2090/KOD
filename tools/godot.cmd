@echo off
setlocal

rem Repo-local Godot entrypoint.
rem Priority:
rem 1) GODOT_EXE env var
rem 2) This machine's default path

if not "%GODOT_EXE%"=="" goto run
set "GODOT_EXE=C:\Users\User\Godot\Godot_v4.6-stable_win64.exe"

:run
if exist "%GODOT_EXE%" (
  "%GODOT_EXE%" %*
  exit /b %ERRORLEVEL%
)

echo ERROR: Godot executable not found.
echo Tried: "%GODOT_EXE%"
echo Set GODOT_EXE to your Godot 4 executable path and retry.
exit /b 1