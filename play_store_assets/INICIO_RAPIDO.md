# 🚀 INICIO RÁPIDO: Imágenes para Play Store

## ⏱️ Tiempo estimado: 30-45 minutos

---

## 📋 RESUMEN ULTRA RÁPIDO

Necesitas **3 tipos de imágenes** para subir Vanelux a Play Store:

1. **6-8 Screenshots** de la app (1080x1920px)
2. **1 Feature Graphic** - banner promocional (1024x500px)
3. **1 Icono** de alta resolución (512x512px)

---

## ⚡ PASOS RÁPIDOS

### Paso 1: Captura Screenshots (15-20 min)

```powershell
# 1. Abre el emulador con tu app
cd "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
flutter run -d emulator-5554

# 2. Ejecuta el script de captura
.\capturar_screenshots.ps1
```

**Pantallas a capturar:**
1. ✅ Login/Bienvenida
2. ✅ Pantalla principal (home con mapa)
3. ✅ Selección de vehículo de lujo
4. ✅ Formulario de reserva
5. ✅ Historial de reservas
6. ✅ Perfil de usuario

---

### Paso 2: Crea Feature Graphic (10-15 min)

**Opción más fácil - Canva:**

1. Ve a: https://www.canva.com
2. Crear diseño → Tamaño personalizado → **1024 x 500**
3. Diseña con:
   - Fondo elegante (negro/azul oscuro)
   - Texto: "VANELUX - Luxury Taxi Service"
   - Imagen de auto de lujo
   - Colores dorado/blanco
4. Descargar como PNG
5. Guardar en: `play_store_assets/feature_graphic/`

**Plantillas sugeridas en Canva:**
- Busca: "banner elegante"
- Busca: "luxury banner"
- Usa colores: negro + dorado

---

### Paso 3: Prepara el Icono (5 min)

Tu app ya tiene un icono. Solo necesitas:

1. Encontrar tu icono actual (512x512px o redimensionarlo)
2. Guardarlo en: `play_store_assets/icon/icon_512x512.png`

**Si necesitas redimensionarlo:**
- Usa: https://iloveimg.com/resize-image
- Redimensiona a: 512 x 512 px
- Mantén formato PNG con transparencia

---

### Paso 4: Verifica Todo (5 min)

Abre la carpeta y revisa:

```powershell
explorer "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app\play_store_assets"
```

**Checklist rápido:**
- [ ] Mínimo 6 screenshots en `screenshots/phone/`
- [ ] Feature graphic de 1024x500 en `feature_graphic/`
- [ ] Icono de 512x512 en `icon/`
- [ ] Todas las imágenes se ven bien y nítidas

---

## 📊 DIMENSIONES - MEMORIZA ESTO

| Qué | Tamaño | Dónde |
|-----|--------|-------|
| Screenshots | 1080 x 1920 | screenshots/phone/ |
| Feature Graphic | 1024 x 500 | feature_graphic/ |
| Icono | 512 x 512 | icon/ |

---

## 🎯 PANTALLAS PRIORITARIAS

Si tienes poco tiempo, captura AL MENOS estas 4:

1. **Home/Login** - Primera impresión
2. **Pantalla principal** - Funcionalidad core
3. **Reserva** - Acción principal
4. **Perfil** - Gestión de cuenta

---

## 🆘 PROBLEMAS COMUNES

### "No sé usar ADB"
→ Usa Ctrl+S en el emulador para capturar manualmente

### "No tengo Photoshop"
→ Usa Canva (gratis, online, super fácil)

### "Mis screenshots son muy grandes/pequeños"
→ Redimensiona en: https://iloveimg.com/resize-image

### "No sé diseñar el Feature Graphic"
→ Sigue la plantilla en `PLANTILLA_FEATURE_GRAPHIC.md`

---

## 📁 TU ESTRUCTURA FINAL

```
play_store_assets/
├── screenshots/phone/
│   ├── 01_login.png ✓
│   ├── 02_home_cliente.png ✓
│   ├── 03_seleccion_vehiculo.png ✓
│   ├── 04_formulario_reserva.png ✓
│   ├── 05_historial_reservas.png ✓
│   └── 06_perfil_usuario.png ✓
├── feature_graphic/
│   └── feature_graphic_1024x500.png ✓
└── icon/
    └── icon_512x512.png ✓
```

---

## 🎨 DISEÑO FEATURE GRAPHIC - VERSIÓN EXPRESS

**Canva - Paso a paso (5 minutos):**

1. Abre Canva → Diseño personalizado → 1024 x 500
2. Fondo: Negro sólido
3. Agrega texto: "VANELUX"
   - Fuente: Montserrat Bold, 80px
   - Color: Dorado (#D4AF37)
4. Agrega subtexto: "Luxury Taxi Service"
   - Fuente: Montserrat Light, 30px
   - Color: Blanco
5. Agrega imagen de auto (busca "luxury car" en Canva)
6. Descarga PNG → ¡Listo!

---

## 📱 CÓMO SUBIR A PLAY STORE

1. Ve a: https://play.google.com/console
2. Selecciona tu app "Vanelux"
3. Menú lateral → "Presencia en la tienda" → "Listado principal"
4. Sección "Recursos gráficos":
   - **Capturas de pantalla del teléfono**: Sube tus 6-8 screenshots
   - **Gráfico destacado**: Sube el Feature Graphic
   - **Icono de la aplicación**: Sube el icono 512x512
5. Guardar → ¡Listo para publicar!

---

## 💡 TIPS EXPRESS

✅ **Haz:**
- Screenshots con datos realistas (no vacíos)
- Feature Graphic simple pero elegante
- Verificar dimensiones antes de subir

❌ **No hagas:**
- Screenshots con errores visibles
- Texto muy pequeño en Feature Graphic
- Usar información personal real

---

## 🔗 ENLACES ÚTILES

- **Canva (diseño):** https://www.canva.com
- **Redimensionar imágenes:** https://iloveimg.com/resize-image
- **Imágenes gratis:** https://unsplash.com/s/photos/luxury-car
- **Play Console:** https://play.google.com/console

---

## 📚 DOCUMENTACIÓN COMPLETA

Si necesitas más detalles:

- **Guía completa:** `GUIA_IMAGENES_PLAY_STORE.md`
- **Checklist detallado:** `play_store_assets/CHECKLIST.md`
- **Plantillas Feature:** `play_store_assets/PLANTILLA_FEATURE_GRAPHIC.md`

---

## 🎯 ¡EMPECEMOS!

**Comando para empezar:**

```powershell
cd "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
flutter run -d emulator-5554
```

Luego navega por tu app y captura las pantallas importantes.

**¿Listo? ¡Vamos! 🚀**

---

**Última actualización:** 9 de diciembre, 2025
