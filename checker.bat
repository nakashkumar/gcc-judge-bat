@echo off

SETLOCAL ENABLEDELAYEDEXPANSION
SET CC=gcc

SET totalTests=0
SET totalPassed=0

!CC! -v >nul 2>&1
if %ERRORLEVEL% GEQ 1 (
  echo !CC! is not configured.
  echo Possible reasons for this error:
  echo - C/C++ compiler is not installed.
  echo - Environment variable PATH is not set.
  EXIT /B %ERRORLEVEL%
) else (
  if not exist tmp (mkdir tmp)
  for /r tests %%i in (*.in) DO (
    CALL :RunTest %%%i
  )
  echo.
  echo Total Tests !totalTests!
  echo Tests Passed !totalPassed!
  echo.
  @del /S /Q tmp >NUL
  @rmdir tmp >NUL
  pause
  EXIT /B %ERRORLEVEL%
)

:RunTest
    CALL :GetToken %~1
    SET /a totalTests+=1
    !CC! src\!qName!.c -o tmp\main >log.txt 2>&1
    if %ERRORLEVEL% EQU 0 (
      .\tmp\main.exe < tests\!tType!\!qName!\!tFile! > .\tmp\output
      if %ERRORLEVEL% EQU 0 (
        CALL :CheckOutput
      ) else (
        CALL :PrintStatus "Failed (Runtime Error)" 
      )
    ) else (
        CALL :PrintStatus "Failed (Compilation Error)"
    )
  ENDLOCAL
EXIT /B 0

:GetToken
  set string=%~1
  SET "tType="
  SET "qName="
  SET "tFile="
  SET "tName="
  for %%a in (%string:\= %) do (
    set tType=!qName!
    set qName=!tFile!
    set tFile=%%a
  )
  for /F "tokens=1 delims=." %%a in ("!tFile!") DO SET tName=%%a
EXIT /B 0

:ReadFile
  set "contents="
  for /f "delims=" %%i in ('type %~1') DO SET contents=!contents! %%i
EXIT /B 0

:PrintStatus
  echo [!tType!] !qName! test#!tName!     %~1
EXIT /B 0

:CheckOutput
  CALL :ReadFile "tmp\output"
  set studentOutput=!contents!
  CALL :ReadFile ".\tests\!tType!\!qName!\!tName!.out"
  set judgeOutput=!contents!
  if !studentOutput! == !judgeOutput! (
    CALL :PrintStatus "Passed :)"
    SET /a totalPassed+=1
  ) else (
    CALL :PrintStatus "Failed :("
  )
EXIT /B 0
