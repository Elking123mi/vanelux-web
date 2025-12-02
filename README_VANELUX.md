# 🚕 VaneLux - Luxury Taxi App

## 🌟 Aplicación de Taxi de Lujo con Backend Global

VaneLux es una aplicación Flutter de última generación para servicios de taxi de lujo, conectada a una base de datos global en Supabase.

---

## ⚡ INICIO RÁPIDO

### 1️⃣ Iniciar Backend
```bash
# Doble clic en:
iniciar_backend.bat
```

### 2️⃣ Probar Conexión
```bash
# Doble clic en:
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

## 📚 DOCUMENTACIÓN

### 📖 Guías Principales
- **[INICIO_RAPIDO.md](INICIO_RAPIDO.md)** - Empieza en 3 pasos ⚡
- **[CONFIGURACION_SUPABASE.md](CONFIGURACION_SUPABASE.md)** - Guía completa paso a paso 📘
- **[RESUMEN_CONFIGURACION.md](RESUMEN_CONFIGURACION.md)** - Resumen ejecutivo 📊
- **[CHECKLIST.md](CHECKLIST.md)** - Lista de verificación ✅

### 🛠️ Scripts Utilitarios
- **`iniciar_backend.bat`** - Inicia el backend de Supabase
- **`probar_conexion.bat`** - Prueba la conexión con el backend
- **`test_supabase_connection.dart`** - Script de prueba automatizado

---

## 🎯 CARACTERÍSTICAS

### ✨ Funcionalidades
- 🔐 **Autenticación segura** con JWT tokens
- 📱 **Registro de usuarios** (pasajeros y conductores)
- 🚗 **Crear y gestionar reservas**
- 🗺️ **Integración con Google Maps**
- 💳 **Pagos con Stripe**
- 🤖 **Asistente con ChatGPT**
- 🌍 **Base de datos global** con Supabase

### 🔧 Tecnologías
- **Frontend:** Flutter 3.9.2
- **Backend:** FastAPI + Supabase (PostgreSQL)
- **Auth:** JWT (access + refresh tokens)
- **Maps:** Google Maps API
- **Pagos:** Stripe API
- **IA:** OpenAI ChatGPT API

---

## 📱 ARQUITECTURA

```
┌─────────────────────┐
│   VaneLux App       │
│   (Flutter)         │
└──────────┬──────────┘
           │
           │ HTTP/REST
           ↓
┌─────────────────────┐
│   Backend API       │
│   (FastAPI)         │
└──────────┬──────────┘
           │
           │ SQL
           ↓
┌─────────────────────┐
│   Supabase          │
│   (PostgreSQL)      │
└─────────────────────┘
```

---

## 🌐 CONFIGURACIÓN ACTUAL

### Desarrollo Local
- **IP:** `192.168.1.43`
- **Puerto:** `3000`
- **URL:** `http://192.168.1.43:3000/api/v1`

### Producción (Próximamente)
- **URL:** `https://vanelux-backend.railway.app`

---

## 📦 ESTRUCTURA DEL PROYECTO

```
luxury_taxi_app/
├── lib/
│   ├── config/
│   │   └── app_config.dart          # Configuración de URLs
│   ├── services/
│   │   ├── api_service.dart         # Cliente HTTP
│   │   └── central_backend_service.dart  # Autenticación
│   ├── models/                      # Modelos de datos
│   ├── screens/                     # Pantallas de la app
│   ├── widgets/                     # Componentes reutilizables
│   └── main.dart                    # Punto de entrada
├── android/                         # Configuración Android
├── ios/                             # Configuración iOS
├── test/                            # Pruebas unitarias
├── pubspec.yaml                     # Dependencias
├── test_supabase_connection.dart   # Script de prueba
├── iniciar_backend.bat             # Iniciar backend
├── probar_conexion.bat             # Probar conexión
└── *.md                            # Documentación
```

---

## 🔌 ENDPOINTS API

### Autenticación
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/register` - Registrar usuario
- `POST /api/v1/auth/refresh` - Renovar token
- `GET /api/v1/auth/me` - Info del usuario
- `POST /api/v1/auth/logout` - Cerrar sesión

### Reservas VaneLux
- `POST /api/v1/vlx/bookings` - Crear reserva
- `GET /api/v1/vlx/bookings` - Listar reservas
- `PATCH /api/v1/vlx/bookings/{id}` - Actualizar reserva

---

## 🧪 PRUEBAS

### Ejecutar Pruebas
```bash
# Prueba de conexión
dart run test_supabase_connection.dart

# Pruebas unitarias
flutter test

# Pruebas con cobertura
flutter test --coverage
```

### Resultados Esperados
```
✅ Backend conectado correctamente
✅ Login exitoso
✅ Información del usuario obtenida
✅ Reserva creada exitosamente
✅ Reservas listadas correctamente
🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE
```

---

## 🛠️ DESARROLLO

### Requisitos
- Flutter SDK ≥ 3.9.2
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode
- Python 3.11+ (para backend)

### Instalación
```bash
# Clonar el repositorio
git clone [URL]

# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Compilar APK
flutter build apk
```

### Variables de Entorno
```bash
# Compilar con URL personalizada
flutter run --dart-define=API_BASE_URL=http://192.168.1.43:3000
```

---

## 📊 ESTADO DEL PROYECTO

- ✅ **Backend:** Configurado con Supabase
- ✅ **Frontend:** Configurado y listo
- ✅ **Autenticación:** JWT funcionando
- ✅ **Reservas:** CRUD completo
- ✅ **Maps:** Google Maps integrado
- ✅ **Pagos:** Stripe integrado
- 🚧 **Producción:** Pendiente de despliegue

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### "Connection refused"
```bash
# Iniciar el backend
iniciar_backend.bat
```

### "401 Unauthorized"
```dart
// Hacer logout y volver a iniciar sesión
await CentralBackendService.logout();
```

### Más ayuda
Consulta **[CONFIGURACION_SUPABASE.md](CONFIGURACION_SUPABASE.md)** - Sección "🆘 SOLUCIÓN DE PROBLEMAS"

---

## 📞 COMANDOS ÚTILES

```bash
# Flutter
flutter clean                    # Limpiar proyecto
flutter pub get                  # Instalar dependencias
flutter run --verbose            # Ejecutar con logs
flutter build apk --release      # Compilar APK de producción

# Backend (PowerShell)
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba\backend"
..\.venv\Scripts\python api_server_supabase.py
```

---

## 🎯 PRÓXIMOS PASOS

### Desarrollo
- [ ] Iniciar backend
- [ ] Probar conexión
- [ ] Ejecutar app
- [ ] Probar funcionalidades

### Producción
- [ ] Desplegar backend en Railway
- [ ] Actualizar URL en app_config.dart
- [ ] Compilar APK/IPA
- [ ] Publicar en tiendas

---

## 🎉 ¡LISTO PARA USAR!

**VaneLux está completamente configurado con Supabase.**

- ✅ Base de datos global funcionando
- ✅ Autenticación segura
- ✅ API REST completa
- ✅ Documentación exhaustiva

**¡Empieza a desarrollar ahora!** 🚀

---

## 📄 LICENCIA

Proyecto privado - Todos los derechos reservados

---

## 👤 AUTOR

**Elkin** - VaneLux Development Team

---

**Última actualización:** 28 de Noviembre, 2025  
**Versión:** 1.0.0
