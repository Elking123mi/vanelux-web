# 📸 Imágenes para Google Play Store - Vanelux

Este directorio contiene todos los recursos gráficos necesarios para publicar Vanelux en Google Play Store.

---

## 📂 Estructura de Carpetas

```
play_store_assets/
├── 📱 screenshots/
│   ├── phone/          ← Screenshots del teléfono (1080x1920)
│   └── tablet/         ← Screenshots de tablet (opcional)
├── 🎨 feature_graphic/  ← Banner promocional (1024x500)
└── 🎯 icon/            ← Icono alta resolución (512x512)
```

---

## ✅ Requisitos de Google Play

| Tipo de Imagen | Dimensiones | Formato | Cantidad | Obligatorio |
|---------------|-------------|---------|----------|-------------|
| Screenshots Phone | 1080 x 1920 px | PNG/JPG | 2-8 | ✅ Sí |
| Feature Graphic | 1024 x 500 px | PNG/JPG | 1 | ✅ Sí |
| Icono App | 512 x 512 px | PNG | 1 | ✅ Sí |
| Screenshots Tablet | 1920 x 1080 px | PNG/JPG | 2-8 | ❌ No |

---

## 🚀 Inicio Rápido

### 1️⃣ Captura Screenshots (15 min)

```powershell
# Ejecuta tu app en el emulador
cd "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
flutter run -d emulator-5554

# Usa el script automático para capturar
.\capturar_screenshots.ps1
```

### 2️⃣ Crea Feature Graphic (10 min)

Usa Canva con estas especificaciones:
- **Tamaño:** 1024 x 500 px
- **Elementos:** Logo + "VANELUX - Luxury Taxi Service" + Auto de lujo
- **Colores:** Negro/Dorado/Blanco
- **Link:** https://www.canva.com

### 3️⃣ Prepara el Icono (5 min)

Redimensiona tu icono actual a 512x512 px

---

## 📋 Documentación

| Archivo | Descripción |
|---------|-------------|
| **[INICIO_RAPIDO.md](INICIO_RAPIDO.md)** | ⚡ Guía express (30 min) |
| **[CHECKLIST.md](CHECKLIST.md)** | ✅ Lista de verificación paso a paso |
| **[PLANTILLA_FEATURE_GRAPHIC.md](PLANTILLA_FEATURE_GRAPHIC.md)** | 🎨 Ideas y plantillas para el banner |

Para la guía completa y detallada: `../GUIA_IMAGENES_PLAY_STORE.md`

---

## 📱 Pantallas a Capturar

Prioridad ALTA (mínimo 6):

1. ✅ **Login/Bienvenida** - Primera impresión
2. ✅ **Home Cliente** - Pantalla principal con mapa
3. ✅ **Selección Vehículo** - Flota de lujo
4. ✅ **Formulario Reserva** - Proceso de booking
5. ✅ **Historial** - Lista de reservas
6. ✅ **Perfil** - Gestión de cuenta

Opcionales:
7. 🔹 Asistente IA - Chat inteligente
8. 🔹 Confirmación - Detalles del viaje

---

## 🎯 Estado Actual

- [ ] Screenshots capturados (0/6 mínimo)
- [ ] Feature Graphic creado
- [ ] Icono preparado
- [ ] Todo revisado y listo para subir

---

## 🔧 Herramientas Recomendadas

- **Diseño gráfico:** [Canva](https://www.canva.com) (gratis)
- **Redimensionar:** [ILoveIMG](https://iloveimg.com/resize-image)
- **Imágenes gratis:** [Unsplash](https://unsplash.com/s/photos/luxury-car)
- **Editor avanzado:** [Photopea](https://www.photopea.com) (gratis)

---

## 💡 Tips Rápidos

✅ **Haz:**
- Usa datos de ejemplo realistas
- Muestra la app funcionando
- Mantén diseño elegante y profesional
- Destaca lo "premium" de Vanelux

❌ **Evita:**
- Pantallas vacías o con errores
- Información personal real
- Imágenes borrosas
- Dimensiones incorrectas

---

## 📞 Ayuda

¿Problemas? Revisa:
1. **INICIO_RAPIDO.md** - Soluciones express
2. **../GUIA_IMAGENES_PLAY_STORE.md** - Guía completa
3. **CHECKLIST.md** - Paso a paso detallado

---

**Creado:** 9 de diciembre, 2025
**App:** Vanelux - Luxury Taxi Service
