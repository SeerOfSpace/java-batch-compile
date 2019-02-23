@echo off
setlocal EnableDelayedExpansion
if "%~1"=="" (
	echo Error: Too few arguments
	pause
	exit
)
set tempDir=%~dp0\...temp
mkdir "%tempDir%"
set count=0
for %%a in (%*) do (
	if exist "%%a\*" (
		call :FOLDERLOOP %%a
	) else (
		if "%%~xa"==".java" (
			call :FILEWORK %%a
		)
	)
	if not !ERRORLEVEL!==0 (
		pause
		goto :END
	)
)
if %count%==0 (
	echo Error: No java files were found
	pause
	goto :END
)
call :INPUTLOOP
call :RUN
:END
rmdir /s /q "%tempDir%"
exit

:FILEWORK
echo Compiling %~1
set /a count+=1
javac "%~1" -d "%tempDir%" 2>"%tempDir%\...tempFile"
if not %ERRORLEVEL%==0 (
	cls
	type "%tempDir%\...tempFile"
	exit /b 1
)
exit /b 0

:FOLDERLOOP
for /r %1 %%a in (*.java) do (
	call :FILEWORK "%%a"
	if not !ERRORLEVEL!==0 (
		exit /b 1
	)
)
exit /b 0

:INPUTLOOP
for /f %%a in ('dir /b /a:d "%tempDir%"^|find /c /v ""') do (set dirCount=%%a)
set package=
set dPackage=
set class=
if not %dirCount%==0 (
	set /p package="Name of package: "
	if defined package (
		set dPackage=!package:.=\!
		call :VALIDATE "%tempDir%\!dPackage!" !dPackage!
		if not !ERRORLEVEL!==0 (
			echo Error: Package not found
			goto :INPUTLOOP
		)
	)
)
set /p class="Name of main class: "
(dir /b /a-d "%tempDir%\%dPackage%\%class%.class"|find "%class%.class") >nul 2>nul
if not %ERRORLEVEL%==0 (
	echo Error: Class not found
	goto :INPUTLOOP
)
goto :eof

:VALIDATE
::cannot check for case sensitivity which can cause errors
(dir /b /a:d "%~dp1"|findstr /x /c:"%~n2") >nul 2>nul
if not %ERRORLEVEL%==0 (
	exit /b 1
)
exit /b 0

:RUN
cls
if "%package%"=="" (
	java -cp "%tempDir%" %class%
) else (
	java -cp "%tempDir%" %package%.%class%
)
pause
if not %ERRORLEVEL%==0 (
	goto :eof
)
call :RERUNLOOP
if %ERRORLEVEL%==0 (
	goto :RUN
)
goto :eof

:RERUNLOOP
set /p rerun="Rerun program? (y/n): "
set result=
if %rerun%==y set result=true
if %rerun%==Y set result=true
if %rerun%==n set result=false
if %rerun%==N set result=false
if not defined result (
	echo Error: Invalid input
	goto :RERUNLOOP
)
if %result%==true (
	exit /b 0
)
exit /b 1