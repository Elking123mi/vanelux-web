# 📱 Guía Completa: Imágenes para Google Play Store - Vanelux App

## 🎯 Requisitos de Google Play Store

### 1. **SCREENSHOTS (Capturas de Pantalla)** - OBLIGATORIOS

#### Para Teléfonos:
- **Cantidad**: Mínimo 2, máximo 8 capturas
- **Formato**: PNG o JPG (24-bit, sin transparencia)
- **Dimensiones**: 
  - Mínimo: 320px
  - Máximo: 3840px
  - El lado más largo no puede ser más de 2 veces el lado más corto
  - **RECOMENDADO**: 1080 x 1920 px (Portrait) o 1920 x 1080 px (Landscape)

#### Para Tablets (Opcional pero recomendado):
- **Cantidad**: Mínimo 2, máximo 8 capturas
- **Formato**: PNG o JPG
- **Dimensiones mínimas**: 1080 x 1920 px

---

### 2. **GRÁFICO DE FUNCIONES (Feature Graphic)** - OBLIGATORIO

- **Formato**: PNG o JPG (24-bit)
- **Dimensiones EXACTAS**: **1024 x 500 px**
- **Sin transparencia**
- **Descripción**: Imagen promocional que aparece en la parte superior de tu página en Play Store

---

### 3. **ICONO DE LA APP** - OBLIGATORIO

- **Formato**: PNG (32-bit con transparencia)
- **Dimensiones**: **512 x 512 px**
- **Descripción**: Icono de alta resolución de tu aplicación

---

### 4. **IMÁGENES ADICIONALES (Opcionales pero recomendadas)**

#### Promo Video:
- URL de YouTube (opcional)

#### Banner TV (si soportas Android TV):
- **1280 x 720 px**

---

## 📸 CAPTURAS DE PANTALLA RECOMENDADAS PARA VANELUX

### Sugerencia de 6-8 Screenshots que debes capturar:

1. **Screenshot 1: Pantalla de Bienvenida/Login**
   - Muestra la elegancia de tu app de taxis de lujo
   - Destaca el logo de Vanelux

2. **Screenshot 2: Pantalla Principal del Cliente (Customer Home)**
   - Mapa con ubicación
   - Botones para solicitar viaje
   - Interfaz limpia y profesional

3. **Screenshot 3: Selección de Vehículo/Servicio**
   - Muestra los diferentes tipos de vehículos de lujo
   - Precios estimados
   - Opciones premium

4. **Screenshot 4: Formulario de Reserva**
   - Selección de origen y destino
   - Fecha y hora
   - Detalles del viaje

5. **Screenshot 5: Historial de Reservas**
   - Lista de viajes completados
   - Detalles de cada reserva
   - Estado de los viajes

6. **Screenshot 6: Perfil de Usuario**
   - Información del usuario
   - Configuraciones
   - Datos de la cuenta

7. **Screenshot 7 (Opcional): Asistente de IA**
   - Muestra el chat con el asistente
   - Interacción inteligente
   - Funcionalidad premium

8. **Screenshot 8 (Opcional): Confirmación de Viaje**
   - Detalles del conductor
   - Información del vehículo
   - Seguimiento en tiempo real

---

## 🚀 CÓMO CAPTURAR LAS PANTALLAS

### Opción 1: Desde el Emulador Android (RECOMENDADO)

1. **Iniciar tu app en el emulador:**
   ```powershell
   cd "c:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
   flutter run -d emulator-5554
   ```

2. **Capturar pantallas:**
   - Navega a cada pantalla importante de tu app
   - Presiona el botón de captura en el emulador o usa: **Ctrl + S** (en el emulador)
   - Las capturas se guardan automáticamente

3. **Ubicación de las capturas:**
   - Por defecto se guardan en: `C:\Users\elkin\Pictures\Screenshots\`
   - O en el escritorio

### Opción 2: Usando ADB (Android Debug Bridge)

1. **Capturar pantalla con ADB:**
   ```powershell
   adb shell screencap -p /sdcard/screenshot.png
   adb pull /sdcard/screenshot.png "c:\Users\elkin\OneDrive\Desktop\vanelux app\screenshots\"
   ```

### Opción 3: Herramientas del Emulador Android Studio

1. Abre Android Studio
2. Ve a: View → Tool Windows → Emulator
3. Haz clic en el botón de cámara (📷) en la barra lateral del emulador

---

## 🎨 CÓMO CREAR EL FEATURE GRAPHIC (1024x500)

### Opción 1: Usando Canva (Recomendado - Gratis)

1. Ve a: https://www.canva.com
2. Crea un diseño personalizado de 1024 x 500 px
3. Agrega:
   - Logo de Vanelux
   - Título: "VANELUX - Luxury Taxi Service"
   - Subtítulo: "Viaja con elegancia y estilo"
   - Imagen de un auto de lujo
   - Colores elegantes (negro, dorado, blanco)

### Opción 2: Usando Photoshop/GIMP

1. Crea un nuevo archivo: 1024 x 500 px
2. Diseña un banner atractivo con el concepto de tu app

### Plantilla de texto para tu Feature Graphic:
```
VANELUX
Servicio Premium de Taxi
Elegancia • Confort • Seguridad
```

---

## 📁 ORGANIZACIÓN DE ARCHIVOS

Crea esta estructura para organizar tus imágenes:

```
play_store_assets/
├── screenshots/
│   ├── phone/
│   │   ├── 01_login.png
│   │   ├── 02_home.png
│   │   ├── 03_booking.png
│   │   ├── 04_vehicle_selection.png
│   │   ├── 05_booking_history.png
│   │   └── 06_profile.png
│   └── tablet/
│       └── (opcional)
├── feature_graphic/
│   └── feature_graphic_1024x500.png
└── icon/
    └── icon_512x512.png
```

---

## ✅ CHECKLIST ANTES DE SUBIR

- [ ] Mínimo 2 screenshots de teléfono (recomendado: 6-8)
- [ ] Feature Graphic de 1024x500 px
- [ ] Icono de 512x512 px
- [ ] Todas las imágenes en formato PNG o JPG
- [ ] Screenshots sin información personal visible
- [ ] Screenshots en resolución mínima de 1080x1920
- [ ] Feature Graphic sin texto pequeño (debe verse bien en móvil)
- [ ] Verificar que las imágenes muestren las mejores funcionalidades

---

## 🎯 CONSEJOS PARA MEJORES SCREENSHOTS

1. **Usa datos de prueba realistas** pero no información personal real
2. **Muestra la app en acción** (no pantallas vacías)
3. **Usa el tema/diseño más atractivo** de tu app
4. **Mantén consistencia visual** entre todas las capturas
5. **Destaca características únicas** de Vanelux
6. **Evita mostrar errores o pantallas de carga**
7. **Usa el idioma principal** de tu audiencia (español)

---

## 🔧 HERRAMIENTAS ÚTILES

### Para editar/optimizar imágenes:
- **Canva** (https://canva.com) - Gratis, fácil de usar
- **GIMP** (https://gimp.org) - Gratis, potente
- **Photopea** (https://photopea.com) - Gratis, online, como Photoshop

### Para crear mockups profesionales:
- **Mockuphone** (https://mockuphone.com) - Gratis
- **Smartmockups** (https://smartmockups.com) - Parcialmente gratis

### Para redimensionar en lote:
- **ILoveIMG** (https://iloveimg.com/resize-image) - Gratis, online

---

## 📝 EJEMPLO DE DESCRIPCIÓN PARA SCREENSHOTS

Cuando subas las imágenes a Play Store, considera agregar títulos descriptivos:

1. "Inicio de sesión elegante y seguro"
2. "Reserva tu viaje de lujo en segundos"
3. "Elige entre nuestra flota premium"
4. "Programa tu viaje con anticipación"
5. "Revisa tu historial de viajes"
6. "Gestiona tu perfil y preferencias"

---

## 🚨 ERRORES COMUNES A EVITAR

❌ Screenshots con bordes negros o marcos de emulador
❌ Imágenes borrosas o de baja calidad
❌ Texto demasiado pequeño para leer
❌ Información personal o de prueba visible (emails, teléfonos reales)
❌ Feature Graphic con dimensiones incorrectas
❌ Imágenes con transparencia donde no está permitida
❌ Screenshots que no muestran la funcionalidad real de la app

---

## 📞 PRÓXIMOS PASOS

1. **Ejecuta tu app en el emulador**
2. **Navega y captura las 6-8 pantallas sugeridas**
3. **Crea el Feature Graphic en Canva**
4. **Organiza todo en la carpeta `play_store_assets/`**
5. **Revisa la calidad y dimensiones**
6. **Sube a Google Play Console**

---

## 💡 ¿NECESITAS AYUDA?

Si necesitas que te ayude a:
- Crear el Feature Graphic
- Ajustar el diseño de alguna pantalla
- Optimizar las imágenes
- Crear mockups profesionales

¡Solo dímelo y te ayudo! 🚀
