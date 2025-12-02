@echo off
REM ===================================================================
REM INICIAR BACKEND DE SUPABASE PARA VANELUX
REM ===================================================================

echo.
echo ========================================
echo    INICIANDO BACKEND SUPABASE
echo ========================================
echo.

cd /d "C:\Users\elkin\OneDrive\Desktop\app de prueba\backend"

IF NOT EXIST ".venv\Scripts\python.exe" (
    echo ERROR: No se encontro el entorno virtual .venv
    echo Por favor, verifica que el entorno virtual este creado.
    echo.
    pause
    exit /b 1
)

echo Activando entorno virtual...
echo.

REM Ejecutar el servidor
.venv\Scripts\python api_server_supabase.py

pause
