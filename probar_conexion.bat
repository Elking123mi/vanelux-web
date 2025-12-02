@echo off
REM ===================================================================
REM PROBAR CONEXION CON SUPABASE
REM ===================================================================

echo.
echo ========================================
echo    PROBANDO CONEXION CON SUPABASE
echo ========================================
echo.

cd /d "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"

echo Ejecutando script de prueba...
echo.

dart run test_supabase_connection.dart

echo.
echo ========================================
pause
