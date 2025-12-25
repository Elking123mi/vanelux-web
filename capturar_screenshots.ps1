# Script para capturar screenshots desde el emulador Android
# Uso: Ejecuta este script después de tener la app corriendo en el emulador

$screenshots_path = "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app\play_store_assets\screenshots\phone"
$counter = 1

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CAPTURADOR DE SCREENSHOTS VANELUX" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Instrucciones:" -ForegroundColor Yellow
Write-Host "1. Asegurate de tener el emulador corriendo con la app" -ForegroundColor White
Write-Host "2. Navega a la pantalla que quieres capturar" -ForegroundColor White
Write-Host "3. Presiona ENTER en esta ventana para capturar" -ForegroundColor White
Write-Host "4. Repite para cada pantalla" -ForegroundColor White
Write-Host "5. Escribe 'salir' para terminar" -ForegroundColor White
Write-Host ""

# Verificar si ADB está disponible
$adb_available = $false
try {
    adb version | Out-Null
    $adb_available = $true
    Write-Host "✓ ADB detectado correctamente" -ForegroundColor Green
} catch {
    Write-Host "✗ ADB no encontrado. Asegurate de tener Android SDK instalado" -ForegroundColor Red
    Write-Host "  Puedes capturar manualmente con Ctrl+S en el emulador" -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Pantallas sugeridas a capturar:" -ForegroundColor Cyan
Write-Host "1. Login/Bienvenida" -ForegroundColor White
Write-Host "2. Home del Cliente" -ForegroundColor White
Write-Host "3. Selección de Vehículo" -ForegroundColor White
Write-Host "4. Formulario de Reserva" -ForegroundColor White
Write-Host "5. Historial de Reservas" -ForegroundColor White
Write-Host "6. Perfil de Usuario" -ForegroundColor White
Write-Host "7. Asistente IA (opcional)" -ForegroundColor White
Write-Host "8. Confirmación de Viaje (opcional)" -ForegroundColor White
Write-Host ""

$screen_names = @(
    "01_login",
    "02_home_cliente",
    "03_seleccion_vehiculo",
    "04_formulario_reserva",
    "05_historial_reservas",
    "06_perfil_usuario",
    "07_asistente_ia",
    "08_confirmacion_viaje"
)

foreach ($screen_name in $screen_names) {
    Write-Host "-------------------------------" -ForegroundColor Gray
    Write-Host "Screenshot $counter de ${screen_names.Count}: $screen_name" -ForegroundColor Yellow
    Write-Host "Navega a la pantalla y presiona ENTER para capturar (o 'salir' para terminar)" -ForegroundColor White
    $input = Read-Host
    
    if ($input -eq "salir" -or $input -eq "exit" -or $input -eq "q") {
        Write-Host "Captura finalizada." -ForegroundColor Green
        break
    }
    
    Write-Host "Capturando..." -ForegroundColor Cyan
    
    # Capturar screenshot con ADB
    $temp_path = "/sdcard/screenshot_temp.png"
    $output_file = "$screenshots_path\$screen_name.png"
    
    adb shell screencap -p $temp_path
    adb pull $temp_path $output_file
    adb shell rm $temp_path
    
    if (Test-Path $output_file) {
        Write-Host "✓ Screenshot guardado: $screen_name.png" -ForegroundColor Green
        
        # Obtener dimensiones
        Add-Type -AssemblyName System.Drawing
        $img = [System.Drawing.Image]::FromFile($output_file)
        $width = $img.Width
        $height = $img.Height
        $img.Dispose()
        
        Write-Host "  Dimensiones: ${width}x${height}px" -ForegroundColor Gray
        
        if ($width -lt 1080 -or $height -lt 1920) {
            Write-Host "  ⚠ Advertencia: Resolución menor a la recomendada (1080x1920)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ Error al guardar screenshot" -ForegroundColor Red
    }
    
    $counter++
    Write-Host ""
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "RESUMEN" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Screenshots capturados: $($counter - 1)" -ForegroundColor Green
Write-Host "Ubicación: $screenshots_path" -ForegroundColor White
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Revisa las capturas en la carpeta" -ForegroundColor White
Write-Host "2. Crea el Feature Graphic (1024x500px)" -ForegroundColor White
Write-Host "3. Prepara el icono (512x512px)" -ForegroundColor White
Write-Host "4. Sube todo a Google Play Console" -ForegroundColor White
Write-Host ""
Write-Host "Abriendo carpeta de screenshots..." -ForegroundColor Cyan
Start-Process explorer.exe $screenshots_path
