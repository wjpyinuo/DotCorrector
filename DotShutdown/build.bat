@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion
echo.
echo  ==================================
echo   DotShutdown - Build Script
echo  ==================================
echo.

:: Check .NET SDK
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET SDK not found.
    echo   Install .NET 8 SDK from: https://dotnet.microsoft.com/download/dotnet/8.0
    pause
    exit /b 1
)

echo [1/5] Checking .NET version...
dotnet --version
echo.

:: Clean
echo [2/5] Cleaning previous builds...
if exist src\bin rd /s /q src\bin
if exist src\obj rd /s /q src\obj
if exist dist rd /s /q dist
echo.

:: Restore
echo [3/5] Restoring packages...
dotnet restore src\DotShutdown.csproj
if errorlevel 1 (
    echo [ERROR] Package restore failed
    pause
    exit /b 1
)
echo.

:: Build
echo [4/5] Building Release (x64)...
dotnet build src\DotShutdown.csproj -c Release -p:Platform=x64 --no-restore
if errorlevel 1 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)
echo.

:: Publish single file
echo [5/5] Publishing self-contained single file...
dotnet publish src\DotShutdown.csproj -c Release -p:Platform=x64 -p:PublishSingleFile=true -p:SelfContained=true -p:IncludeNativeLibrariesForSelfExtract=true -p:EnableCompressionInSingleFile=true --output dist\x64

if errorlevel 1 (
    echo [ERROR] Publish failed
    pause
    exit /b 1
)

echo.
echo  ==================================
echo   Build Complete!
echo  ==================================
echo.
echo   Output: dist\x64\DotShutdown.exe
echo.
echo  Usage:
echo    DotShutdown.exe                    Launch GUI
echo    DotShutdown.exe --cli -t 30        CLI mode (30 min shutdown)
echo    DotShutdown.exe --cli --cancel     Cancel pending shutdown
echo    DotShutdown.exe --cli -h           Show CLI help
echo.
pause
