@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION
SET CC=gcc

SET totalTests=0
SET totalPassed=0

!CC! -v >NUL 2>&1
IF %ERRORLEVEL% GEQ 1 (
  ECHO !CC! is not configured.
  EXIT /B %ERRORLEVEL%
) ELSE (
  IF not EXIST tmp (mkdir tmp)
  FOR /r tests %%i in (*.in) DO (
    CALL :RunTest "%%i"
  )
  ECHO.
  ECHO Total Tests !totalTests!
  ECHO Tests Passed !totalPassed!
  ECHO.
  DEL /S /Q tmp >NUL
  RMDIR tmp >NUL
  PAUSE
  EXIT /B %ERRORLEVEL%
)

:RunTest
    CALL :GetToken "%~1"
    SET /a totalTests+=1
    !CC! src\!qName!.c -o tmp\main >log.txt 2>&1
    IF %ERRORLEVEL% EQU 0 (
      .\tmp\main.exe < tests\!tType!\!qName!\!tFile! > .\tmp\output
      CALL :CheckOutput
    ) ELSE (
        CALL :PrintStatus "Failed (Compilation Error)"
    )
  ENDLOCAL
EXIT /B 0

:GetToken
  SET string=%~1
  SET "tType="
  SET "qName="
  SET "tFile="
  SET "tName="
  FOR %%a in (%string:\= %) DO (
    SET tType=!qName!
    SET qName=!tFile!
    SET tFile=%%a
  )
  FOR /F "tokens=1 delims=." %%a in ("!tFile!") DO SET tName=%%a
EXIT /B 0

:ReadFile
  SET "contents="
  FOR /f "delims=" %%i in ('type %~1') DO SET contents=!contents! %%i
EXIT /B 0

:PrintStatus
  ECHO [!tType!] !qName! test#!tName!     %~1
EXIT /B 0

:CheckOutput
  CALL :ReadFile "tmp\output"
  SET studentOutput=!contents!
  CALL :ReadFile ".\tests\!tType!\!qName!\!tName!.out"
  SET judgeOutput=!contents!
  IF !studentOutput! == !judgeOutput! (
    CALL :PrintStatus "Passed :)"
    SET /a totalPassed+=1
  ) ELSE (
    CALL :PrintStatus "Failed :("
  )
EXIT /B 0
