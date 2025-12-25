# 📋 Checklist: Imágenes Play Store - Vanelux

## ✅ LISTA DE VERIFICACIÓN

### 1. Screenshots de Teléfono (OBLIGATORIO)
- [ ] **01_login.png** - Pantalla de inicio/login (1080x1920)
- [ ] **02_home_cliente.png** - Home del cliente con mapa (1080x1920)
- [ ] **03_seleccion_vehiculo.png** - Selección de vehículo de lujo (1080x1920)
- [ ] **04_formulario_reserva.png** - Formulario de reserva (1080x1920)
- [ ] **05_historial_reservas.png** - Lista de reservas (1080x1920)
- [ ] **06_perfil_usuario.png** - Perfil del usuario (1080x1920)
- [ ] **07_asistente_ia.png** - Chat con asistente (opcional)
- [ ] **08_confirmacion_viaje.png** - Detalles del viaje (opcional)

**Mínimo requerido: 2 screenshots | Recomendado: 6-8**

---

### 2. Feature Graphic (OBLIGATORIO)
- [ ] **feature_graphic_1024x500.png** 
  - Dimensiones: 1024 x 500 px (EXACTAS)
  - Formato: PNG o JPG
  - Sin transparencia
  - Diseño atractivo con logo y mensaje de Vanelux

---

### 3. Icono de Alta Resolución (OBLIGATORIO)
- [ ] **icon_512x512.png**
  - Dimensiones: 512 x 512 px
  - Formato: PNG con transparencia
  - Mismo diseño que el icono de la app

---

### 4. Verificación de Calidad
- [ ] Todas las imágenes están en formato PNG o JPG
- [ ] No hay información personal visible
- [ ] Screenshots muestran la app funcionando (no pantallas vacías)
- [ ] Resolución mínima cumplida (1080x1920 para screenshots)
- [ ] Feature Graphic tiene dimensiones exactas
- [ ] Todas las imágenes se ven nítidas y profesionales
- [ ] Colores consistentes con la marca Vanelux
- [ ] No hay errores o bugs visibles en las capturas

---

## 🚀 CÓMO USAR ESTE CHECKLIST

### Paso 1: Ejecuta la app
```powershell
cd "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
flutter run -d emulator-5554
```

### Paso 2: Captura las pantallas

**Opción A - Manual:**
- Navega a cada pantalla
- Presiona Ctrl+S en el emulador para capturar
- Guarda en: `play_store_assets/screenshots/phone/`

**Opción B - Semi-automático:**
```powershell
.\capturar_screenshots.ps1
```

### Paso 3: Crea el Feature Graphic
1. Ve a https://www.canva.com
2. Crea diseño personalizado: 1024 x 500 px
3. Usa plantilla sugerida (ver guía completa)
4. Exporta como PNG
5. Guarda en: `play_store_assets/feature_graphic/`

### Paso 4: Prepara el icono
1. Copia tu icono actual
2. Redimensiona a 512 x 512 px
3. Guarda en: `play_store_assets/icon/`

### Paso 5: Revisa todo
- Abre cada imagen y verifica calidad
- Comprueba dimensiones
- Verifica que no hay errores

### Paso 6: Sube a Play Store
1. Ve a Google Play Console
2. Selecciona tu app
3. Ve a "Presencia en la tienda" > "Listado principal"
4. Sube las imágenes en las secciones correspondientes

---

## 📏 DIMENSIONES RÁPIDAS

| Tipo | Dimensiones | Formato | Obligatorio |
|------|-------------|---------|-------------|
| Screenshots Phone | 1080 x 1920 px | PNG/JPG | Sí (mín. 2) |
| Feature Graphic | 1024 x 500 px | PNG/JPG | Sí |
| Icono | 512 x 512 px | PNG | Sí |
| Screenshots Tablet | 1920 x 1080 px | PNG/JPG | No |

---

## 💡 TIPS RÁPIDOS

✅ **Haz esto:**
- Usa datos de ejemplo realistas
- Muestra las mejores funciones
- Mantén consistencia visual
- Destaca lo "premium" de Vanelux

❌ **Evita esto:**
- Pantallas vacías o con errores
- Información personal real
- Imágenes borrosas
- Dimensiones incorrectas

---

## 📁 ESTRUCTURA DE CARPETAS

```
play_store_assets/
├── screenshots/
│   └── phone/
│       ├── 01_login.png ✓
│       ├── 02_home_cliente.png ✓
│       ├── 03_seleccion_vehiculo.png ✓
│       ├── 04_formulario_reserva.png ✓
│       ├── 05_historial_reservas.png ✓
│       └── 06_perfil_usuario.png ✓
├── feature_graphic/
│   └── feature_graphic_1024x500.png ✓
└── icon/
    └── icon_512x512.png ✓
```

---

## 🎯 ESTADO ACTUAL

**Fecha de inicio:** 9 de diciembre, 2025

**Screenshots capturados:** 0 / 6 (mínimo)

**Feature Graphic:** ⬜ Pendiente

**Icono:** ⬜ Pendiente

**Listo para subir:** ⬜ No

---

## 📞 ¿NECESITAS AYUDA?

Si tienes problemas con:
- Capturar las pantallas → Usa el script `capturar_screenshots.ps1`
- Crear el Feature Graphic → Sigue las instrucciones en `GUIA_IMAGENES_PLAY_STORE.md`
- Redimensionar imágenes → Usa https://iloveimg.com/resize-image
- Diseño gráfico → Usa https://www.canva.com

---

**¡Marca cada item cuando lo completes! ✨**
