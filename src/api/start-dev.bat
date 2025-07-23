@echo off
title ATS Server Management API - Development

echo.
echo ==========================================
echo   ATS Server Management API
echo   Development Server
echo ==========================================
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if we're in the api directory
if not exist "package.json" (
    echo Error: package.json not found
    echo Please run this script from the api directory
    pause
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo Creating .env file from template...
    copy ".env.example" ".env"
    echo.
    echo ⚠️  IMPORTANT: Please edit .env file with your configuration
    echo.
)

REM Create logs directory
if not exist "logs" mkdir logs

echo Starting development server...
echo.
echo 🚀 API will be available at: http://localhost:3001
echo 📊 Health check: http://localhost:3001/health
echo 📝 Logs will be written to: ./logs/
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the development server
npm run dev

pause
