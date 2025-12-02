# INSTRUCCIONES URGENTES PARA EL AGENTE DEL BACKEND

## 🚨 PROBLEMA CRÍTICO
Las reservas de VaneLux NO se están guardando en el backend. Se guardan solo localmente en cada dispositivo y no sincronizan entre plataformas.

## ✅ SOLUCIÓN REQUERIDA

### Implementar 2 endpoints en FastAPI:

---

## 1️⃣ POST /api/v1/vlx/bookings - Crear reserva

**Ruta completa:** `http://localhost:3000/api/v1/vlx/bookings`

**Headers requeridos:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body (ejemplo):**
```json
{
  "pickup_address": "123 Main St, New York, NY",
  "pickup_lat": 40.7128,
  "pickup_lng": -74.0060,
  "destination_address": "456 Park Ave, New York, NY",
  "destination_lat": 40.7580,
  "destination_lng": -73.9855,
  "pickup_time": "2025-11-28T14:30:00Z",
  "vehicle_name": "Mercedes S-Class",
  "passengers": 2,
  "price": 150.50,
  "distance_miles": 5.2,
  "distance_text": "5.2 mi",
  "duration_text": "15 min",
  "service_type": "luxury",
  "is_scheduled": true
}
```

**Campos opcionales en el payload:**
- `distanceMiles`, `distanceText`, `durationText`
- `serviceType`, `isScheduled`, `metadata`

**Response esperada:**
```json
{
  "booking": {
    "id": 1,
    "user_id": 2,
    "origin": "123 Main St, New York, NY",
    "destination": "456 Park Ave, New York, NY",
    "pickup_time": "2025-11-28T14:30:00Z",
    "passengers": 2,
    "fare": 150.50,
    "status": "pending",
    "created_at": "2025-11-27T10:00:00Z",
    "updated_at": "2025-11-27T10:00:00Z"
  }
}
```

**Lógica del endpoint:**
1. Extraer `user_id` del JWT token
2. Validar campos requeridos: `pickup_address`, `destination_address`, `pickup_time`, `fare`
3. Insertar en tabla `vlx_bookings`:
   ```sql
   INSERT INTO vlx_bookings (
     user_id, 
     origin, 
     destination, 
     pickup_time, 
     passengers, 
     fare, 
     status
   ) VALUES (?, ?, ?, ?, ?, ?, 'pending')
   ```
4. Retornar el registro creado con su ID

**Validaciones:**
- `origin` y `destination` no pueden estar vacíos
- `pickup_time` debe ser una fecha válida
- `fare` debe ser positivo
- `passengers` debe ser >= 1
- `user_id` se obtiene del token JWT (usuario autenticado)

---

## 2️⃣ GET /api/v1/vlx/bookings - Listar reservas del usuario

**Ruta completa:** `http://localhost:3000/api/v1/vlx/bookings`

**Headers requeridos:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Query parameters (opcionales):**
- `page`: número de página (default: 1)
- `page_size`: registros por página (default: 50)
- `status`: filtrar por estado (pending, confirmed, completed, cancelled)

**Response esperada:**
```json
{
  "bookings": [
    {
      "id": 1,
      "user_id": 2,
      "origin": "123 Main St, New York, NY",
      "destination": "456 Park Ave, New York, NY",
      "pickup_time": "2025-11-28T14:30:00Z",
      "passengers": 2,
      "fare": 150.50,
      "status": "pending",
      "created_at": "2025-11-27T10:00:00Z",
      "updated_at": "2025-11-27T10:00:00Z"
    }
  ]
}
```

**Lógica del endpoint:**
1. Extraer `user_id` del JWT token
2. Consultar reservas del usuario:
   ```sql
   SELECT * FROM vlx_bookings 
   WHERE user_id = ? 
   ORDER BY created_at DESC
   ```
3. Aplicar filtros si existen (status, paginación)
4. Retornar lista de reservas

**IMPORTANTE:** Solo retornar las reservas del usuario autenticado (filtrar por `user_id`)

---

## 📊 Tabla en la base de datos

**Tabla:** `vlx_bookings` (ya existe en logistics.db)

**Estructura actual:**
```sql
CREATE TABLE vlx_bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    origin TEXT NOT NULL,
    destination TEXT NOT NULL,
    pickup_time TEXT NOT NULL,
    passengers INTEGER DEFAULT 1,
    fare REAL,
    status TEXT DEFAULT 'pending',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**Estados válidos para `status`:**
- `pending` - Reserva creada, esperando confirmación
- `confirmed` - Reserva confirmada
- `in_progress` - Viaje en progreso
- `completed` - Viaje completado
- `cancelled` - Reserva cancelada

---

## 🔐 Autenticación

**Ambos endpoints REQUIEREN autenticación JWT:**

1. El token se envía en el header: `Authorization: Bearer <token>`
2. Extraer `user_id` del payload del JWT
3. Usar ese `user_id` para:
   - POST: Asignar la reserva al usuario
   - GET: Filtrar solo las reservas de ese usuario

**Ejemplo de validación:**
```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    # Decodificar JWT y extraer user_id
    payload = decode_jwt(token)
    return payload['user_id']
```

---

## 🧪 Cómo probar

### 1. Verificar que los endpoints existen:
```bash
# En el proyecto de backend
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba"

# Iniciar servidor
python -m uvicorn main:app --reload --port 3000
# O el comando correcto según tu configuración
```

### 2. Probar con curl (después de hacer login):

**Login primero:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"ampueroelkin@gmail.com\",\"password\":\"tu_contraseña\"}"
```

Copiar el `access_token` de la respuesta.

**Crear reserva:**
```bash
curl -X POST http://localhost:3000/api/v1/vlx/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN_AQUI>" \
  -d "{\"pickup_address\":\"Test origin\",\"destination_address\":\"Test destination\",\"pickup_time\":\"2025-11-28T14:00:00Z\",\"passengers\":2,\"fare\":100.0}"
```

**Listar reservas:**
```bash
curl http://localhost:3000/api/v1/vlx/bookings \
  -H "Authorization: Bearer <TOKEN_AQUI>"
```

### 3. Verificar en la base de datos:

```bash
# Desde la carpeta de VaneLux
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
python monitor_reservas.py
```

Deberías ver las reservas creadas.

---

## 🎯 Checklist de implementación

- [ ] Endpoint POST /api/v1/vlx/bookings implementado
- [ ] Endpoint GET /api/v1/vlx/bookings implementado
- [ ] Ambos requieren autenticación JWT
- [ ] POST inserta en tabla `vlx_bookings` con `user_id` del token
- [ ] GET filtra por `user_id` del token
- [ ] Validaciones de campos implementadas
- [ ] Respuestas en formato JSON correcto
- [ ] Servidor corriendo en puerto 3000
- [ ] Probado con curl/Postman y funciona

---

## 📍 Ubicación de archivos

- **Base de datos:** `C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db`
- **Backend:** `C:\Users\elkin\OneDrive\Desktop\app de prueba\` (tu proyecto FastAPI)
- **Flutter:** `C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app\`

---

## ⚡ URGENTE

Una vez implementados los endpoints:
1. Iniciar el backend
2. Avisar que está listo
3. El equipo de Flutter probará creando una reserva desde la app
4. Verificarán que aparece en todas las plataformas (web, Windows, móvil)

---

## 💡 Nota importante

El código de Flutter YA ESTÁ LISTO y esperando estos endpoints. Tiene logs detallados que mostrarán:
- 🔵 Información de conexión
- ✅ Éxito al guardar/consultar  
- ❌ Errores con detalles

Solo falta que implementes estos 2 endpoints en el backend.
