@echo off
setlocal enabledelayedexpansion
set xdir=%~dp0
if "%~1"=="" (
    set noask=0
) else (
    set noask=1
)

if not exist "%USERPROFILE%\.config\wezterm" (
  mklink /D "%USERPROFILE%\.config\wezterm"  %xdir%
) else (
  if %noask%==1 (
    move "%USERPROFILE%\.config\wezterm" "%USERPROFILE%\.config\wezterm.bak"
    mklink /D "%USERPROFILE%\.config\wezterm"  %xdir%
  ) else (
    echo .config\wezterm config exist, will you override[y/n]?
    set /p choice=
    if !choice!==y (
      move "%USERPROFILE%\.config\wezterm" "%USERPROFILE%\.config\wezterm.bak"
      mklink /D "%USERPROFILE%\.config\wezterm"  %xdir%
    ) else (
      echo dont override exist config.
    )
  )
)
