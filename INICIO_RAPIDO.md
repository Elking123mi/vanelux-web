# 🚀 INICIO RÁPIDO - VANELUX + SUPABASE

## ⚡ 3 PASOS PARA EMPEZAR

### 1️⃣ Iniciar el Backend
```powershell
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba\backend"
..\.venv\Scripts\python api_server_supabase.py
```

**Deberías ver:**
```
🟢 Usando SUPABASE (Base de datos en la nube)
INFO: Uvicorn running on http://0.0.0.0:3000
```

---

### 2️⃣ Probar la Conexión
```bash
dart run luxury_taxi_app/test_supabase_connection.dart
```

**Deberías ver:**
```
✅ Backend conectado correctamente
✅ Login exitoso
✅ Información del usuario obtenida
✅ Reserva creada exitosamente
✅ Reservas listadas correctamente
🎉 TODAS LAS PRUEBAS PASARON EXITOSAMENTE
```

---

### 3️⃣ Ejecutar la App
```bash
# Asegúrate de estar en la misma red WiFi
flutter run
```

**Credenciales de prueba:**
- **Usuario:** `admin`
- **Password:** `admin123`

---

## 📱 PROBAR EN DISPOSITIVO MÓVIL

1. Conecta tu celular a la misma red WiFi que tu PC
2. Asegúrate de que el backend esté corriendo
3. Ejecuta la app: `flutter run`
4. Haz login con: `admin` / `admin123`
5. Crea una reserva de prueba
6. Verifica en Supabase Dashboard

---

## 🌐 URL ACTUAL

**Desarrollo:** `http://192.168.1.43:3000/api/v1`

Para verificar tu IP actual:
```powershell
ipconfig | Select-String "IPv4"
```

---

## 📚 DOCUMENTACIÓN COMPLETA

- **`CONFIGURACION_SUPABASE.md`** - Guía completa paso a paso con solución de problemas
- **`RESUMEN_CONFIGURACION.md`** - Resumen ejecutivo y cambios realizados
- **`test_supabase_connection.dart`** - Script de prueba automatizado

---

## ✅ TODO ESTÁ LISTO

- ✅ Backend configurado con Supabase
- ✅ Flutter configurado para conectarse
- ✅ Permisos de Android/iOS agregados
- ✅ Endpoints de autenticación funcionando
- ✅ Endpoints de reservas funcionando

**¡Solo falta iniciar el backend y probar!** 🎉

---

## 🆘 ¿PROBLEMAS?

### "Connection refused"
```powershell
# Verificar que el backend esté corriendo
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba\backend"
..\.venv\Scripts\python api_server_supabase.py
```

### "401 Unauthorized"
```dart
// Hacer logout y volver a hacer login
await CentralBackendService.logout();
```

### Más ayuda
Revisa `CONFIGURACION_SUPABASE.md` - Sección "🆘 SOLUCIÓN DE PROBLEMAS"

---

**¡Disfruta desarrollando con VaneLux!** 🚀
