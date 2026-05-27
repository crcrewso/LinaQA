@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: run_script.bat
:: Runs a Python script via Anaconda/Miniconda (local or system)
:: Usage: LinaQA.bat <file_or_directory>
:: ============================================================

:: --- Check argument (optional) ---
set "TARGET=%~1"

:: --- Python script to run (edit this to your script path) ---
set "PYTHON_SCRIPT=%~dp0LinaQA\LinaQA.pyw"

:: ============================================================
:: Locate conda installation
:: Search order:
::   1. User-local Anaconda
::   2. User-local Miniconda
::   3. System-wide Anaconda (ProgramData)
::   4. System-wide Miniconda (ProgramData)
::   5. CONDA_PREFIX / CONDA_EXE environment variables
::   6. conda on PATH
:: ============================================================

set "CONDA_ROOT="

:: 1. User-local Anaconda
if exist "%USERPROFILE%\anaconda3\Scripts\activate.bat" (
    set "CONDA_ROOT=%USERPROFILE%\anaconda3"
    goto :found_conda
)

:: 2. User-local Miniconda
if exist "%USERPROFILE%\miniconda3\Scripts\activate.bat" (
    set "CONDA_ROOT=%USERPROFILE%\miniconda3"
    goto :found_conda
)

:: 3. System-wide Anaconda
if exist "%ProgramData%\anaconda3\Scripts\activate.bat" (
    set "CONDA_ROOT=%ProgramData%\anaconda3"
    goto :found_conda
)

:: 4. System-wide Miniconda
if exist "%ProgramData%\miniconda3\Scripts\activate.bat" (
    set "CONDA_ROOT=%ProgramData%\miniconda3"
    goto :found_conda
)

:: 5a. Fall back to CONDA_PREFIX env var
if defined CONDA_PREFIX (
    if exist "%CONDA_PREFIX%\Scripts\activate.bat" (
        set "CONDA_ROOT=%CONDA_PREFIX%"
        goto :found_conda
    )
)

:: 5b. Fall back to CONDA_EXE env var (strip \Scripts\conda.exe)
if defined CONDA_EXE (
    for %%F in ("%CONDA_EXE%") do set "CONDA_ROOT=%%~dpF.."
    if exist "!CONDA_ROOT!\Scripts\activate.bat" goto :found_conda
    set "CONDA_ROOT="
)

:: 6. Try conda on PATH
where conda >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [INFO] conda found on PATH; using system PATH activation.
    goto :use_path_conda
)

:: Nothing found
echo [ERROR] Could not locate Anaconda or Miniconda.
echo         Install conda or add it to your PATH and retry.
exit /b 1

:: ============================================================
:found_conda
echo [INFO] Conda root : !CONDA_ROOT!

:: Initialise conda for this cmd session
call "!CONDA_ROOT!\Scripts\activate.bat" "!CONDA_ROOT!"

:: --- Optional: activate a specific environment ---
:: Uncomment and set ENV_NAME to use a named environment,
:: otherwise the base environment is used.
:: set "ENV_NAME=myenv"
:: if defined ENV_NAME (
::     call conda activate %ENV_NAME%
::     if !ERRORLEVEL! neq 0 (
::         echo [ERROR] Failed to activate conda environment: %ENV_NAME%
::         exit /b 1
::     )
:: )

goto :run_python

:: ============================================================
:use_path_conda
:: conda is on PATH but root is unknown; activate base directly
call conda activate base
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to activate base conda environment.
    exit /b 1
)

:: ============================================================
:run_python
echo [INFO] Python     : 
python --version
if defined TARGET (echo [INFO] Target     : %TARGET%) else (echo [INFO] Target     : ^(none^))
echo [INFO] Script     : %PYTHON_SCRIPT%
echo.

if not exist "%PYTHON_SCRIPT%" (
    echo [ERROR] Python script not found: %PYTHON_SCRIPT%
    exit /b 1
)

if defined TARGET (
    python "%PYTHON_SCRIPT%" "%TARGET%"
) else (
    python "%PYTHON_SCRIPT%"
)

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Script exited with code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

echo.
echo [INFO] Done.
endlocal
