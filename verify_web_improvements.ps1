# Vanelux Web - Script de Verificacion Pre-Deploy
# PowerShell Script para verificar que todas las mejoras esten implementadas

Write-Host "Vanelux Web - Verificacion Pre-Deploy" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app\web"
$errors = 0
$warnings = 0

Write-Host "Verificando archivos creados..." -ForegroundColor Cyan
Write-Host ""

# Archivos basicos
$files = @(
    @{Path="$baseDir\robots.txt"; Name="robots.txt"},
    @{Path="$baseDir\sitemap.xml"; Name="sitemap.xml"},
    @{Path="$baseDir\_headers"; Name="_headers (security)"},
    @{Path="$baseDir\netlify.toml"; Name="netlify.toml"},
    @{Path="$baseDir\browserconfig.xml"; Name="browserconfig.xml"},
    @{Path="$baseDir\humans.txt"; Name="humans.txt"},
    @{Path="$baseDir\SECURITY.md"; Name="SECURITY.md"},
    @{Path="$baseDir\jfk-limo.html"; Name="JFK Limo landing page"},
    @{Path="$baseDir\airport-transfer.html"; Name="Airport Transfer landing page"},
    @{Path="$baseDir\corporate-transportation.html"; Name="Corporate landing page"}
)

foreach ($file in $files) {
    if (Test-Path $file.Path) {
        Write-Host "OK $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "FALTA $($file.Name)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "Verificando contenido de index.html..." -ForegroundColor Cyan
Write-Host ""

if (Test-Path "$baseDir\index.html") {
    $indexContent = Get-Content "$baseDir\index.html" -Raw
    
    $checks = @(
        @{Pattern='<html lang="en">'; Name="HTML lang attribute"},
        @{Pattern="loading-splash"; Name="Splash screen"},
        @{Pattern="whatsapp-float"; Name="WhatsApp floating button"},
        @{Pattern='rel="preload"'; Name="Preload tags"},
        @{Pattern="LocalBusiness"; Name="LocalBusiness schema"},
        @{Pattern="aggregateRating"; Name="Aggregate rating schema"}
    )
    
    foreach ($check in $checks) {
        if ($indexContent -match $check.Pattern) {
            Write-Host "OK $($check.Name)" -ForegroundColor Green
        } else {
            Write-Host "ADVERTENCIA $($check.Name) - No encontrado" -ForegroundColor Yellow
            $warnings++
        }
    }
} else {
    Write-Host "ERROR index.html no existe" -ForegroundColor Red
    $errors++
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Resumen
if ($errors -eq 0 -and $warnings -eq 0) {
    Write-Host "PERFECTO! Todas las verificaciones pasaron." -ForegroundColor Green
    Write-Host "Listo para deploy a produccion." -ForegroundColor Green
} elseif ($errors -eq 0) {
    Write-Host "Verificacion completada con $warnings advertencias." -ForegroundColor Yellow
} else {
    Write-Host "Verificacion FALLIDA: $errors errores, $warnings advertencias" -ForegroundColor Red
}

Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Cyan
Write-Host "1. flutter build web --release --web-renderer auto"
Write-Host "2. Verificar build/web/ tiene todos los archivos"
Write-Host "3. Deploy a Netlify"
Write-Host ""

