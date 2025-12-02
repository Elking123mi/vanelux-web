# 🚀 VaneLux - Conectado a Railway + Supabase

**Fecha:** 2 de Diciembre, 2025  
**Estado:** ✅ CONFIGURADO Y LISTO PARA PROBAR

---

## 🌐 **URLs del Backend**

### **Backend en Railway (24/7):**
```
https://web-production-700fe.up.railway.app
```

### **Documentación API:**
```
https://web-production-700fe.up.railway.app/docs
```

### **Endpoints Base:**
```
https://web-production-700fe.up.railway.app/api/v1
```

---

## ✅ **Cambios Realizados**

### **1. Archivo de Configuración Actualizado**
📂 `lib/config/app_config.dart`

```dart
// ANTES: Localhost
static String get apiBaseUrl {
  return const String.fromEnvironment('API_BASE_URL', 
    defaultValue: 'http://192.168.1.43:3000');
}

// DESPUÉS: Railway en la nube
static String get apiBaseUrl {
  return const String.fromEnvironment('API_BASE_URL', 
    defaultValue: 'https://web-production-700fe.up.railway.app');
}
```

### **2. Login Actualizado con Identificador de App**
📂 `lib/services/central_backend_service.dart`

```dart
// Ahora envía 'app': 'vanelux' al backend
body: jsonEncode({
  'username': email, 
  'password': password,
  'app': requiredApp,  // ← 'vanelux'
}),
```

---

## 👥 **Usuarios de Prueba**

### **Usuario 1: Elkin Jeremias** ⭐ ✅ VALIDADO
```
📧 Email: elkinjeremias123@gmail.com
🔑 Password: azlanzapata143@
✅ Acceso: VaneLux + Conexaship
🎭 Roles: Pasajero + Cliente
� Estado: PROBADO Y FUNCIONANDO EN RAILWAY
```

### **Usuario 2: Elkin Chila** ✅ VALIDADO
```
📧 Email: chilaelkin4@gmail.com
🔑 Password: chila123
✅ Acceso: VaneLux + Conexaship
🎭 Rol: Cliente
🔬 Estado: PROBADO Y FUNCIONANDO EN RAILWAY
```

> **⚠️ NOTA IMPORTANTE:** Los usuarios `ampueroelkin@gmail.com` y `admin@example.com` mencionados en la documentación original **NO EXISTEN** en el backend actual de Railway. Usa los usuarios de arriba que están validados y funcionando.

---

## 🧪 **Cómo Probar la Conexión**

### **1. Ejecutar la App**
```bash
# Windows
flutter run -d windows

# Android
flutter run -d emulator-5554

# Web
flutter run -d chrome
```

### **2. Iniciar Sesión**
1. Abre la app VaneLux
2. Usa uno de los usuarios de prueba (arriba)
3. Si el login funciona → ✅ Conectado a Railway

### **3. Crear una Reserva**
1. Inicia sesión exitosamente
2. Selecciona origen y destino en el mapa
3. Elige un vehículo (Sedan, SUV, Van)
4. Selecciona fecha y hora
5. Confirma la reserva
6. Si la reserva se crea → ✅ Guardada en Supabase

### **4. Ver Mis Reservas**
1. Ve a "Mis Reservas" en el menú
2. Deberías ver todas tus reservas guardadas
3. Prueba desde otra plataforma (Windows → Android)
4. Las reservas deben aparecer en ambas → ✅ Sincronización funcionando

---

## 🔍 **Verificar en Supabase**

### **Ver Reservas en la Base de Datos:**
1. Ir a: https://app.supabase.com
2. Seleccionar proyecto: `logisticsbackend`
3. Ir a **Table Editor** → `vlx_bookings`
4. Ver todas las reservas creadas desde las apps

### **Ver Usuarios:**
1. Ir a **Table Editor** → `users`
2. Ver todos los usuarios registrados
3. Verificar campo `allowed_apps` incluye `vanelux`

---

## 🚨 **Errores Comunes y Soluciones**

### **Error: "No tienes acceso a VaneLux"**
**Causa:** El usuario no tiene `vanelux` en `allowed_apps`

**Solución:**
1. Usa uno de los usuarios de prueba listados arriba
2. O actualiza el usuario en Supabase:
   - Ir a tabla `users`
   - Editar el usuario
   - Campo `allowed_apps`: agregar `"vanelux"`

### **Error: "Connection timeout" o "Network error"**
**Causa:** No se puede conectar a Railway

**Solución:**
1. Verifica tu conexión a internet
2. Abre en el navegador: `https://web-production-700fe.up.railway.app/`
3. Debería mostrar:
   ```json
   {
     "message": "VaneLux/Conexaship API",
     "version": "2.0.0",
     "database": "Supabase (Cloud)"
   }
   ```
4. Si no abre, el backend puede estar inactivo en Railway

### **Error: "Invalid username or password"**
**Causa:** Credenciales incorrectas

**Solución:**
- Copia y pega exactamente las credenciales de arriba
- No agregues espacios extra

### **Error: "401 Unauthorized" al crear reserva**
**Causa:** Token expirado

**Solución:**
1. Cierra sesión (logout)
2. Inicia sesión de nuevo
3. Intenta crear la reserva nuevamente

---

## 📊 **Arquitectura del Sistema**

```
┌──────────────────────────────────────────────────┐
│         VaneLux Apps (Flutter)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Windows  │  │ Android  │  │   Web    │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
└───────┼─────────────┼─────────────┼──────────────┘
        │             │             │
        └─────────────┼─────────────┘
                      │ HTTPS
                      ▼
┌──────────────────────────────────────────────────┐
│    Backend FastAPI (Railway - 24/7)              │
│    https://web-production-700fe.up.railway.app   │
│                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐ │
│  │   Auth     │  │  Bookings  │  │   Users    │ │
│  │ JWT Tokens │  │ VaneLux    │  │  Management│ │
│  └────────────┘  └────────────┘  └────────────┘ │
└───────────────────────┬──────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────┐
│   Base de Datos PostgreSQL (Supabase)           │
│   https://ujkddikmljvccpwrgnvz.supabase.co      │
│                                                   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐ │
│  │   users    │  │vlx_bookings│  │refresh_    │ │
│  │            │  │            │  │ tokens     │ │
│  └────────────┘  └────────────┘  └────────────┘ │
└──────────────────────────────────────────────────┘
```

---

## 📱 **Endpoints Disponibles**

### **Autenticación**
- `POST /api/v1/auth/login` - Login con email/contraseña
- `POST /api/v1/auth/login-card` - Login con tarjeta RFID
- `POST /api/v1/auth/register` - Registrar nuevo usuario
- `POST /api/v1/auth/refresh` - Refrescar token
- `GET /api/v1/auth/me` - Obtener usuario actual

### **VaneLux - Reservas**
- `GET /api/v1/vlx/bookings` - Listar mis reservas
- `POST /api/v1/vlx/bookings` - Crear nueva reserva
- `PATCH /api/v1/vlx/bookings/{id}` - Actualizar reserva
- `DELETE /api/v1/vlx/bookings/{id}` - Cancelar reserva

### **Usuarios**
- `GET /api/v1/users` - Listar usuarios (admin)
- `GET /api/v1/users/{id}` - Ver usuario específico
- `POST /api/v1/users` - Crear usuario (admin)
- `PATCH /api/v1/users/{id}` - Actualizar usuario

---

## 🎯 **Próximos Pasos**

### **✅ Completados:**
1. Backend desplegado en Railway
2. Base de datos en Supabase configurada
3. App VaneLux conectada al backend
4. Login con verificación de `allowed_apps`

### **🔜 Por Hacer:**
1. Probar login desde todas las plataformas (Windows, Android, Web)
2. Crear reservas de prueba y verificar sincronización
3. Probar desde múltiples dispositivos simultáneamente
4. Configurar dominio personalizado (opcional): `vanelux.com`
5. Desplegar Flutter Web en Netlify
6. Publicar apps en tiendas (Play Store, App Store)

---

## 📞 **Enlaces Importantes**

- **Backend Railway:** https://railway.app/project/[tu-proyecto]
- **Supabase Dashboard:** https://app.supabase.com/project/ujkddikmljvccpwrgnvz
- **GitHub Backend:** https://github.com/Elking123mi/backend-conexaship-vanelux
- **API Docs:** https://web-production-700fe.up.railway.app/docs

---

## 💡 **Notas Importantes**

✅ **Tu PC ya NO necesita estar encendida** - El backend corre 24/7 en Railway  
✅ **Sincronización Global** - Todas las apps comparten la misma base de datos  
✅ **Gratis hasta $5/mes** - Railway incluye $5 de crédito mensual  
✅ **Escalable** - Puede crecer según tus necesidades  
✅ **Seguro** - JWT tokens, HTTPS, base de datos en la nube  

---

**¡VaneLux está ahora conectado a la nube!** 🎉🚀

**Última actualización:** 2 de Diciembre, 2025
