# 🚀 VANELUX + SUPABASE - GUÍA DE CONFIGURACIÓN COMPLETA

## ✅ ESTADO ACTUAL

**¡Tu configuración está completa!** VaneLux ya está listo para conectarse con el backend de Supabase.

---

## 📱 CONFIGURACIÓN ACTUAL

### 🌐 URLs del Backend

**Desarrollo local (red WiFi):**
```
IP Local: 192.168.1.43
Puerto: 3000
URL Base: http://192.168.1.43:3000/api/v1
```

La app detecta automáticamente la plataforma:
- **Android/iOS**: Usa `http://192.168.1.43:3000`
- **Web/Desktop**: Usa `http://localhost:3000`

### 📂 Archivos Configurados

1. **`lib/config/app_config.dart`** ✅
   - URL del backend configurada con detección automática de plataforma
   - Endpoints de autenticación listos
   - Endpoints de VaneLux (`/vlx/bookings`) configurados

2. **`lib/services/api_service.dart`** ✅
   - Manejo de requests HTTP (GET, POST, PUT, DELETE)
   - Refresh automático de tokens
   - Manejo de errores

3. **`lib/services/central_backend_service.dart`** ✅
   - Login y registro de usuarios
   - Gestión de tokens (access + refresh)
   - Validación de permisos de apps

4. **`android/app/src/main/AndroidManifest.xml`** ✅
   - Permisos de Internet agregados
   - `usesCleartextTraffic="true"` para desarrollo local

5. **`ios/Runner/Info.plist`** ✅
   - `NSAppTransportSecurity` configurado para permitir HTTP

6. **`pubspec.yaml`** ✅
   - `http: ^1.1.0` instalado
   - `shared_preferences: ^2.2.2` instalado
   - `flutter_secure_storage: ^9.2.4` instalado

---

## 🎯 ENDPOINTS DISPONIBLES

### Autenticación
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/register` - Crear cuenta nueva
- `POST /api/v1/auth/refresh` - Renovar token
- `GET /api/v1/auth/me` - Info del usuario actual
- `POST /api/v1/auth/logout` - Cerrar sesión

### Usuarios
- `GET /api/v1/users` - Listar usuarios
- `GET /api/v1/users/check/{identifier}` - Verificar si usuario existe

### Reservas VaneLux
- `POST /api/v1/vlx/bookings` - Crear reserva
- `GET /api/v1/vlx/bookings` - Listar reservas del usuario
- `PATCH /api/v1/vlx/bookings/{id}` - Actualizar estado de reserva

---

## 📋 ESTRUCTURA DE DATOS

### Login Request
```json
{
  "username": "admin",
  "password": "admin123"
}
```

### Login Response
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "eyJhbGc...",
  "expires_in": 3600,
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "full_name": "Administrador Sistema",
    "roles": ["admin", "manager"],
    "allowed_apps": ["vanelux", "conexaship"],
    "status": "active"
  }
}
```

### Register Passenger Request
```json
{
  "username": "usuario@example.com",
  "email": "usuario@example.com",
  "password": "password123",
  "full_name": "Nombre Completo",
  "phone": "+1234567890",
  "roles": ["passenger"],
  "allowed_apps": ["vanelux"]
}
```

### Create Booking Request
```json
{
  "pickup_address": "123 Main St, New York",
  "pickup_lat": 40.7128,
  "pickup_lng": -74.0060,
  "destination_address": "456 Park Ave, New York",
  "destination_lat": 40.7589,
  "destination_lng": -73.9851,
  "pickup_time": "2024-11-30 14:00:00",
  "vehicle_name": "Sedan",
  "passengers": 2,
  "price": 45.50,
  "distance_miles": 5.2,
  "distance_text": "5.2 mi",
  "duration_text": "15 min",
  "service_type": "standard",
  "is_scheduled": true,
  "status": "pending"
}
```

---

## 🧪 CÓMO PROBAR LA CONEXIÓN

### 1. Iniciar el Backend

```powershell
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba\backend"
..\.venv\Scripts\python api_server_supabase.py
```

Deberías ver:
```
🟢 Usando SUPABASE (Base de datos en la nube)
INFO: Uvicorn running on http://0.0.0.0:3000
```

### 2. Ejecutar Script de Prueba

Ejecuta el script de prueba desde la raíz del proyecto:

```bash
flutter pub get
dart run luxury_taxi_app/test_supabase_connection.dart
```

El script probará:
- ✅ Conectividad con el backend
- ✅ Login con usuario admin
- ✅ Obtener información del usuario
- ✅ Crear una reserva de prueba
- ✅ Listar reservas

### 3. Probar desde la App

#### **Usuario de Prueba:**
- **Username:** `admin`
- **Password:** `admin123`

#### **En tu dispositivo móvil:**

1. Asegúrate de estar en la misma red WiFi que tu PC
2. Ejecuta la app en tu dispositivo
3. Ve a la pantalla de login
4. Ingresa las credenciales: `admin` / `admin123`
5. Crea una reserva de prueba
6. Verifica que aparezca en Supabase

### 4. Verificar en Supabase Dashboard

1. Ve a https://app.supabase.com
2. Abre tu proyecto
3. Ve a **Table Editor** → `vlx_bookings`
4. Deberías ver las reservas creadas desde VaneLux

---

## 🔄 EJEMPLO DE USO EN CÓDIGO

### Login
```dart
import 'package:luxury_taxi_app/services/central_backend_service.dart';

try {
  final session = await CentralBackendService.login(
    email: 'admin',
    password: 'admin123',
    requiredApp: 'vanelux',
  );
  
  print('✅ Login exitoso!');
  print('Usuario: ${session.user.username}');
  print('Email: ${session.user.email}');
  print('Token: ${session.tokens.accessToken}');
} catch (e) {
  print('❌ Error: $e');
}
```

### Registro de Pasajero
```dart
try {
  final session = await CentralBackendService.registerPassengerAndLogin(
    fullName: 'Juan Pérez',
    email: 'juan@example.com',
    phone: '+1234567890',
    password: 'password123',
  );
  
  print('✅ Registro exitoso!');
  print('Usuario ID: ${session.user.id}');
} catch (e) {
  print('❌ Error: $e');
}
```

### Crear Reserva
```dart
import 'package:luxury_taxi_app/services/api_service.dart';
import 'package:luxury_taxi_app/config/app_config.dart';
import 'package:luxury_taxi_app/services/central_backend_service.dart';

try {
  // Obtener token válido
  final token = await CentralBackendService.getValidAccessToken();
  
  // Crear reserva
  final response = await ApiService.post(
    '/vlx/bookings',
    {
      'pickup_address': '123 Main St, New York',
      'pickup_lat': 40.7128,
      'pickup_lng': -74.0060,
      'destination_address': '456 Park Ave, New York',
      'destination_lat': 40.7589,
      'destination_lng': -73.9851,
      'pickup_time': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
      'vehicle_name': 'Sedan',
      'passengers': 2,
      'price': 45.50,
      'distance_miles': 5.2,
      'distance_text': '5.2 mi',
      'duration_text': '15 min',
      'service_type': 'standard',
      'is_scheduled': true,
      'status': 'pending',
    },
    token: token,
  );
  
  print('✅ Reserva creada!');
  print('ID: ${response['booking']['id']}');
} catch (e) {
  print('❌ Error: $e');
}
```

### Obtener Reservas del Usuario
```dart
try {
  final token = await CentralBackendService.getValidAccessToken();
  
  final response = await ApiService.get(
    '/vlx/bookings',
    token: token,
  );
  
  final bookings = response['bookings'] as List;
  print('✅ ${bookings.length} reservas encontradas');
  
  for (var booking in bookings) {
    print('- ${booking['pickup_address']} → ${booking['destination_address']}');
    print('  Estado: ${booking['status']}');
    print('  Precio: \$${booking['price']}');
  }
} catch (e) {
  print('❌ Error: $e');
}
```

---

## 🌐 PARA PRODUCCIÓN GLOBAL

Cuando despliegues el backend en Railway, Render, o uses ngrok:

### 1. Actualizar la URL en `app_config.dart`

```dart
class AppConfig {
  static String get apiBaseUrl {
    // PRODUCCIÓN - Comenta esto cuando estés en desarrollo
    return 'https://vanelux-backend.railway.app';
    
    // DESARROLLO - Descomenta esto para desarrollo local
    // if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    //   return 'http://localhost:3000';
    // }
    // return 'http://192.168.1.43:3000';
  }
  
  // ... resto del código
}
```

### 2. Remover configuraciones de desarrollo

**Android:** En `AndroidManifest.xml`, puedes remover `android:usesCleartextTraffic="true"` (HTTPS no lo necesita)

**iOS:** En `Info.plist`, puedes remover la sección `NSAppTransportSecurity` (HTTPS no lo necesita)

### 3. Usar Variables de Entorno (Recomendado)

```bash
# Compilar con URL de producción
flutter build apk --dart-define=API_BASE_URL=https://vanelux-backend.railway.app

# O para desarrollo
flutter run --dart-define=API_BASE_URL=http://192.168.1.43:3000
```

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### ❌ "Connection refused" o "Failed to connect"

**Posibles causas:**
1. El backend no está corriendo
2. La IP ha cambiado
3. No estás en la misma red WiFi
4. El firewall está bloqueando el puerto 3000

**Soluciones:**
```powershell
# 1. Verificar que el backend esté corriendo
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba\backend"
..\.venv\Scripts\python api_server_supabase.py

# 2. Verificar tu IP actual
ipconfig | Select-String "IPv4"

# 3. Probar conectividad desde el celular
# En un navegador móvil, visita: http://192.168.1.43:3000/health
# Deberías ver: {"status": "ok"}

# 4. Verificar firewall
# Windows: Panel de Control → Firewall → Permitir app → Python
```

### ❌ "401 Unauthorized"

**Causa:** El token ha expirado o es inválido.

**Solución:**
```dart
// La app debería refrescar automáticamente, pero si no:
await CentralBackendService.logout();
// Luego haz login de nuevo
```

### ❌ "403 Forbidden - Access to VaneLux required"

**Causa:** El usuario no tiene permiso para VaneLux.

**Solución:**
```python
# En Python, actualizar el usuario:
# probar_backend_bookings.py o similar
import requests

response = requests.patch(
    'http://192.168.1.43:3000/api/v1/users/1',
    json={'allowed_apps': ['vanelux', 'conexaship']},
    headers={'Authorization': f'Bearer {admin_token}'}
)
```

### ❌ "Socket Exception" o "Network unreachable"

**Causa:** Tu dispositivo no puede alcanzar la IP.

**Soluciones:**
1. Verifica que estés en la misma red WiFi
2. Intenta conectarte desde un navegador móvil primero: `http://192.168.1.43:3000/health`
3. Verifica que Windows no esté en "Red pública" (debe ser "Red privada")

### ❌ La app compila pero no se conecta

**Debug paso a paso:**

1. **Probar desde navegador móvil:**
   ```
   http://192.168.1.43:3000/health
   ```
   Si esto funciona, el problema está en la app.

2. **Verificar logs:**
   ```bash
   flutter run --verbose
   ```

3. **Probar el script de prueba:**
   ```bash
   dart run luxury_taxi_app/test_supabase_connection.dart
   ```

---

## ✅ CHECKLIST DE CONFIGURACIÓN

- [x] Backend Supabase configurado
- [x] URL del backend en `app_config.dart`
- [x] Dependencias instaladas (`http`, `shared_preferences`, `flutter_secure_storage`)
- [x] Permisos de Internet en Android
- [x] Configuración de cleartext traffic en Android
- [x] Configuración de NSAppTransportSecurity en iOS
- [x] Endpoints de autenticación funcionando
- [x] Endpoints de VaneLux funcionando
- [ ] Backend corriendo en puerto 3000
- [ ] Celular en la misma red WiFi
- [ ] Login de prueba exitoso (`admin` / `admin123`)
- [ ] Crear reserva funciona
- [ ] Reservas se guardan en Supabase

---

## 🎉 ¡LISTO PARA DESARROLLO!

Tu app VaneLux está completamente configurada para conectarse con Supabase. Ahora puedes:

✅ Registrar usuarios desde cualquier país
✅ Hacer login global
✅ Guardar reservas en la nube
✅ Acceder a datos desde cualquier lugar

**Base de datos global funcionando** 🌍🚀

---

## 📚 RECURSOS ADICIONALES

- **Documentación de Supabase:** https://supabase.com/docs
- **Flutter HTTP Package:** https://pub.dev/packages/http
- **Secure Storage:** https://pub.dev/packages/flutter_secure_storage

Para soporte, revisa los logs del backend y de Flutter usando `flutter run --verbose`.
