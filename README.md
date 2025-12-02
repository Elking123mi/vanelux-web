# 🚕 VaneLux - Luxury Taxi App

![Status](https://img.shields.io/badge/status-configured-brightgreen)
![Backend](https://img.shields.io/badge/backend-Supabase-green)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)

Aplicación Flutter de última generación para servicios de taxi de lujo, conectada a una base de datos global en Supabase.

---

## ⚡ INICIO RÁPIDO

### 1️⃣ Iniciar Backend
```bash
# Doble clic en el archivo:
iniciar_backend.bat
```

### 2️⃣ Probar Conexión
```bash
# Doble clic en el archivo:
probar_conexion.bat
```

### 3️⃣ Ejecutar App
```bash
flutter run
```

**Credenciales de prueba:**
- Usuario: `admin`
- Password: `admin123`

---

## 📚 DOCUMENTACIÓN COMPLETA

### 🌟 **[EMPIEZA_AQUI.md](EMPIEZA_AQUI.md)** ← **LÉEME PRIMERO**

### 📖 Guías Disponibles
- **[INICIO_RAPIDO.md](INICIO_RAPIDO.md)** - Empieza en 3 pasos (2 min)
- **[CONFIGURACION_SUPABASE.md](CONFIGURACION_SUPABASE.md)** - Guía completa (15 min)
- **[INDICE_DOCUMENTACION.md](INDICE_DOCUMENTACION.md)** - Navegación entre docs
- **[CHECKLIST.md](CHECKLIST.md)** - Lista de verificación
- **[RESUMEN_VISUAL.md](RESUMEN_VISUAL.md)** - Resumen con diagramas

---

## ✨ CARACTERÍSTICAS

- 🔐 **Autenticación segura** con JWT tokens
- 📱 **Registro de usuarios** (pasajeros y conductores)
- 🚗 **Crear y gestionar reservas**
- 🗺️ **Integración con Google Maps**
- 💳 **Pagos con Stripe**
- 🤖 **Asistente con ChatGPT**
- 🌍 **Base de datos global** con Supabase

---

## 🔧 CONFIGURACIÓN

### Estado Actual
- ✅ Backend Supabase configurado
- ✅ Flutter configurado y listo
- ✅ Permisos Android/iOS agregados
- ✅ Endpoints API funcionando
- ✅ Scripts de prueba creados
- ✅ Documentación completa (1800+ líneas)

### URL de Desarrollo
- **IP Local:** `192.168.1.43`
- **Puerto:** `3000`
- **URL Base:** `http://192.168.1.43:3000/api/v1`

---

## 🧪 PRUEBAS

```bash
# Prueba automatizada
dart run test_supabase_connection.dart

# Pruebas unitarias
flutter test
```

---

## 🎯 ENDPOINTS DISPONIBLES

### Autenticación
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `GET /api/v1/auth/me`

### Reservas VaneLux
- `POST /api/v1/vlx/bookings`
- `GET /api/v1/vlx/bookings`
- `PATCH /api/v1/vlx/bookings/{id}`

---

## 🆘 ¿PROBLEMAS?

### "Connection refused"
```bash
iniciar_backend.bat
```

### Más ayuda
👉 **[CONFIGURACION_SUPABASE.md](CONFIGURACION_SUPABASE.md)** - Sección "🆘 TROUBLESHOOTING"

---

## 📦 ESTRUCTURA

```
luxury_taxi_app/
├── lib/
│   ├── config/          # Configuración (URLs, API keys)
│   ├── services/        # Servicios (API, Auth)
│   ├── models/          # Modelos de datos
│   ├── screens/         # Pantallas
│   └── widgets/         # Componentes
├── android/             # Configuración Android
├── ios/                 # Configuración iOS
├── test/                # Pruebas
└── *.md                 # Documentación
```

---

## 🚀 COMANDOS ÚTILES

```bash
# Instalar dependencias
flutter pub get

# Ejecutar app
flutter run

# Compilar APK
flutter build apk --release

# Ver logs detallados
flutter run --verbose
```

---

## 🎉 ¡LISTO!

Tu aplicación está 100% configurada con Supabase. 

**👉 Lee [EMPIEZA_AQUI.md](EMPIEZA_AQUI.md) para comenzar**

---

**Versión:** 1.0.0  
**Última actualización:** 28 de Noviembre, 2025  
**Estado:** ✅ Completado al 100%
