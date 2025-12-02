# VaneLux Flutter - Integración con Backend

## 📋 Resumen

La app Flutter de VaneLux está completamente integrada con el backend Python central. Todos los usuarios, autenticación y datos se gestionan a través de las APIs REST del backend.

## 🔧 Configuración

### 1. URL del Backend

El backend está configurado en `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = 'http://localhost:3000';
```

**Para producción**, cambiar a:
```dart
static const String apiBaseUrl = 'https://api.tudominio.com';
```

O usar variables de entorno al compilar:
```bash
flutter build apk --dart-define=API_BASE_URL=https://api.tudominio.com
```

### 2. Endpoints Disponibles

#### Autenticación
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - Logout
- `POST /api/v1/auth/register` - Registro
- `GET /api/v1/auth/me` - Usuario actual

#### VaneLux Específicos
- `POST /api/v1/vlx/passengers` - Crear pasajero
- `GET /api/v1/vlx/passengers` - Obtener pasajeros
- `PATCH /api/v1/vlx/passengers/{id}` - Actualizar pasajero
- `POST /api/v1/vlx/drivers` - Crear conductor
- `GET /api/v1/vlx/drivers` - Obtener conductores
- `PATCH /api/v1/vlx/drivers/{id}` - Actualizar conductor
- `GET /api/v1/vlx/trips` - Obtener viajes
- `POST /api/v1/vlx/trips` - Crear viaje

## 🔐 Sistema de Autenticación

### Flujo de Login

1. Usuario ingresa email/password en `LoginScreen`
2. `AuthService.login()` llama a `CentralBackendService.login()`
3. Backend devuelve:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "...",
  "expires_in": 3600,
  "user": {
    "id": 123,
    "email": "user@example.com",
    "roles": ["passenger"],
    "allowed_apps": ["vanelux"]
  }
}
```
4. Tokens se guardan en `flutter_secure_storage`
5. Se valida que `allowed_apps` contenga "vanelux"
6. Navega a `HomeScreen` o `DriverHomeScreen`

### Validación de `allowed_apps`

**Pasajero:**
```dart
user.allowed_apps = ["vanelux"]
```

**Conductor:**
```dart
user.allowed_apps = ["vanelux", "vanelux_driver"]
```

Si el usuario no tiene "vanelux" en `allowed_apps`, el login falla con:
```
Tu cuenta no tiene acceso a "vanelux". Pide a un administrador que actualice tus allowed_apps.
```

### Refresh Token Automático

`ApiService` detecta automáticamente errores 401 y refresca el token:

```dart
if (response.statusCode == 401) {
  await CentralBackendService.refreshTokens();
  response = await call(); // Reintentar
}
```

## 👥 Registro de Usuarios

### Registro de Pasajero

```dart
await AuthService.register(
  name: 'Juan Pérez',
  email: 'juan@example.com',
  password: 'SecurePass123!',
  phone: '+57 300 1234567',
);
// Automáticamente crea usuario con allowed_apps: ["vanelux"]
```

### Registro de Conductor

```dart
await AuthService.registerDriver(
  name: 'María López',
  email: 'maria@example.com',
  password: 'SecurePass123!',
  phone: '+57 310 7654321',
  licenseNumber: 'D123456',
  vehicleMake: 'Mercedes-Benz',
  vehicleModel: 'S-Class',
  vehicleYear: 2023,
);
// Automáticamente crea usuario con allowed_apps: ["vanelux", "vanelux_driver"]
```

## 🛠️ Servicios Disponibles

### AuthService
- `login()` - Autenticar usuario
- `register()` - Registrar pasajero
- `registerDriver()` - Registrar conductor
- `logout()` - Cerrar sesión
- `isAuthenticated()` - Verificar si está autenticado
- `getCurrentUser()` - Obtener usuario actual
- `getCurrentDriver()` - Obtener perfil de conductor

### PassengerService
- `createPassengerProfile()` - Crear perfil adicional
- `getCurrentPassengerProfile()` - Obtener perfil
- `updatePassengerProfile()` - Actualizar datos
- `isPassenger()` - Validar si es pasajero

### DriverService
- `createDriverProfile()` - Crear perfil adicional
- `getCurrentDriverProfile()` - Obtener perfil
- `updateDriverProfile()` - Actualizar datos
- `updateAvailability()` - Cambiar disponibilidad
- `isDriver()` - Validar si es conductor
- `getAvailableDrivers()` - Lista de conductores disponibles

### StorageService
- `requestPresignedUrls()` - Solicitar URLs firmadas
- `uploadToPresignedUrl()` - Subir archivos a S3

## 🧪 Pruebas

### Ejecutar Tests
```bash
cd luxury_taxi_app
flutter test
```

### Test Manual con el Backend

1. **Levantar el backend:**
```bash
# En la carpeta del backend Python
python -m uvicorn main:app --reload --port 3000
```

2. **Ejecutar la app:**
```bash
cd luxury_taxi_app
flutter run
```

3. **Probar login:**
   - Email: `test@vanelux.com`
   - Password: `Test123!`

4. **Verificar en logs:**
```
POST http://localhost:3000/api/v1/auth/login
✓ Token recibido
✓ Usuario tiene allowed_apps: ["vanelux"]
→ Navega a HomeScreen
```

## 🔍 Debugging

### Ver requests HTTP

Activar logs en `api_service.dart`:
```dart
if (AppConfig.enableLogging) {
  print('🌐 ${request.method} ${request.url}');
  print('📤 Body: ${request.body}');
  print('📥 Response: ${response.body}');
}
```

### Errores comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `Connection refused` | Backend no está corriendo | Iniciar backend en puerto 3000 |
| `401 Unauthorized` | Token expirado | Se refresca automáticamente |
| `403 Forbidden` | Falta `allowed_apps` | Admin debe agregar "vanelux" al usuario |
| `404 Not Found` | Endpoint incorrecto | Verificar URL en `AppConfig` |

### Verificar tokens guardados

```dart
final storage = FlutterSecureStorage();
final accessToken = await storage.read(key: 'central_access_token');
final refreshToken = await storage.read(key: 'central_refresh_token');
print('Access Token: $accessToken');
print('Refresh Token: $refreshToken');
```

## 📱 Navegación según Rol

```dart
final user = await AuthService.getCurrentUser();

if (user.allowedApps.contains('vanelux_driver')) {
  // Es conductor → DriverHomeScreen
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => DriverHomeScreen()
  ));
} else {
  // Es pasajero → HomeScreen
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => HomeScreen()
  ));
}
```

## 🚀 Deployment

### Android
```bash
flutter build apk --dart-define=API_BASE_URL=https://api.vanelux.com --release
```

### iOS
```bash
flutter build ios --dart-define=API_BASE_URL=https://api.vanelux.com --release
```

### Web
```bash
flutter build web --dart-define=API_BASE_URL=https://api.vanelux.com --release
```

## 📚 Documentación Adicional

- [Backend API Docs](http://localhost:3000/docs) - Swagger/OpenAPI
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [HTTP Package](https://pub.dev/packages/http)

## ✅ Checklist de Integración

- [x] URLs del backend configuradas
- [x] `AuthService` con login/refresh/logout
- [x] Validación de `allowed_apps`
- [x] Registro de pasajeros y conductores
- [x] `PassengerService` y `DriverService`
- [x] `StorageService` para uploads
- [x] Refresh token automático en `ApiService`
- [x] Navegación según rol (pasajero/conductor)
- [x] Manejo de errores 401/403/404
- [x] Tests unitarios

## 🤝 Soporte

Si encuentras problemas:

1. Verificar que el backend esté corriendo en `http://localhost:3000`
2. Revisar logs en la consola de Flutter
3. Comprobar que el usuario tenga `allowed_apps: ["vanelux"]`
4. Validar que los endpoints del backend coincidan con `AppConfig`

---

**Última actualización:** Noviembre 2025
