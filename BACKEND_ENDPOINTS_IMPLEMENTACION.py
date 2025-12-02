"""
ENDPOINTS PARA AGREGAR AL BACKEND FASTAPI
==========================================

Estos endpoints deben agregarse al archivo principal del backend (main.py o similar).
Implementan la autenticación y gestión de reservas de VaneLux.

UBICACIÓN: C:\Users\elkin\OneDrive\Desktop\app de prueba\main.py (o el archivo principal)
BASE DE DATOS: C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import jwt
import sqlite3
from passlib.context import CryptContext

# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================

SECRET_KEY = "tu_clave_secreta_jwt"  # Cambiar por la clave que uses
ALGORITHM = "HS256"
DATABASE_PATH = "logistics.db"  # Ajustar según la ubicación

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

# ==============================================================================
# MODELOS PYDANTIC
# ==============================================================================

class LoginRequest(BaseModel):
    username: str
    password: str
    app: str = "vanelux"

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: dict

class BookingCreate(BaseModel):
    pickup_address: str
    pickup_lat: Optional[float] = None
    pickup_lng: Optional[float] = None
    destination_address: str
    destination_lat: Optional[float] = None
    destination_lng: Optional[float] = None
    pickup_time: str
    vehicle_name: Optional[str] = None
    passengers: int = 1
    price: float
    distance_miles: Optional[float] = None
    distance_text: Optional[str] = None
    duration_text: Optional[str] = None
    service_type: Optional[str] = "standard"
    is_scheduled: bool = True

class BookingResponse(BaseModel):
    id: int
    user_id: int
    pickup_address: str
    pickup_lat: Optional[float]
    pickup_lng: Optional[float]
    destination_address: str
    destination_lat: Optional[float]
    destination_lng: Optional[float]
    pickup_time: str
    vehicle_name: Optional[str]
    passengers: int
    price: float
    distance_miles: Optional[float]
    distance_text: Optional[str]
    duration_text: Optional[str]
    service_type: str
    is_scheduled: int
    status: str
    created_at: str
    updated_at: str

# ==============================================================================
# FUNCIONES AUXILIARES
# ==============================================================================

def get_db_connection():
    """Crea conexión a la base de datos SQLite"""
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica contraseña hasheada"""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict) -> str:
    """Crea token JWT"""
    to_encode = data.copy()
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_token(token: str) -> dict:
    """Decodifica token JWT"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Obtiene usuario actual desde el token JWT"""
    token = credentials.credentials
    payload = decode_token(token)
    user_id = payload.get("user_id")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
        )
    return user_id

# ==============================================================================
# ROUTER (Agregar al app principal)
# ==============================================================================

router = APIRouter(prefix="/api", tags=["VaneLux"])

# ==============================================================================
# ENDPOINT 1: LOGIN
# ==============================================================================

@router.post("/auth/login", response_model=LoginResponse)
async def login(credentials: LoginRequest):
    """
    Autentica usuario y devuelve token JWT.
    
    **Uso:**
    ```bash
    curl -X POST http://192.168.1.43:3000/api/auth/login \
      -H "Content-Type: application/json" \
      -d '{"username":"chilaelkin4@gmail.com","password":"chila123","app":"vanelux"}'
    ```
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Buscar usuario por email o username
    cursor.execute("""
        SELECT id, username, email, password_hash, roles, allowed_apps, status 
        FROM users 
        WHERE (email = ? OR username = ?) AND status = 'active'
    """, (credentials.username, credentials.username))
    
    user = cursor.fetchone()
    conn.close()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
    
    # Verificar contraseña
    if not verify_password(credentials.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
    
    # Verificar que el usuario tiene acceso a la app solicitada
    import json
    allowed_apps = json.loads(user["allowed_apps"]) if user["allowed_apps"] else []
    if credentials.app not in allowed_apps:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"User does not have access to {credentials.app}"
        )
    
    # Crear token JWT
    token_data = {
        "user_id": user["id"],
        "email": user["email"],
        "username": user["username"]
    }
    access_token = create_access_token(token_data)
    
    # Preparar respuesta
    user_data = {
        "id": user["id"],
        "username": user["username"],
        "email": user["email"],
        "roles": json.loads(user["roles"]) if user["roles"] else [],
        "allowed_apps": allowed_apps
    }
    
    return LoginResponse(
        access_token=access_token,
        user=user_data
    )

# ==============================================================================
# ENDPOINT 2: CREAR RESERVA
# ==============================================================================

@router.post("/vlx/bookings")
async def create_booking(booking: BookingCreate, user_id: int = Depends(get_current_user)):
    """
    Crea una nueva reserva para el usuario autenticado.
    
    **Uso:**
    ```bash
    curl -X POST http://192.168.1.43:3000/api/vlx/bookings \
      -H "Authorization: Bearer <TOKEN>" \
      -H "Content-Type: application/json" \
      -d '{
        "pickup_address": "Aeropuerto Tocumen",
        "pickup_lat": 9.0714,
        "pickup_lng": -79.3834,
        "destination_address": "Hotel Miramar",
        "destination_lat": 9.0047,
        "destination_lng": -79.5047,
        "pickup_time": "2025-11-28T14:00:00Z",
        "vehicle_name": "Mercedes S-Class",
        "passengers": 2,
        "price": 150.50,
        "service_type": "luxury",
        "is_scheduled": true
      }'
    ```
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Insertar reserva
        cursor.execute("""
            INSERT INTO vlx_bookings (
                user_id, 
                pickup_address, 
                pickup_lat, 
                pickup_lng,
                destination_address, 
                destination_lat, 
                destination_lng,
                pickup_time, 
                vehicle_name,
                passengers, 
                price,
                distance_miles,
                distance_text,
                duration_text,
                service_type,
                is_scheduled,
                status,
                created_at,
                updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', datetime('now'), datetime('now'))
        """, (
            user_id,
            booking.pickup_address,
            booking.pickup_lat,
            booking.pickup_lng,
            booking.destination_address,
            booking.destination_lat,
            booking.destination_lng,
            booking.pickup_time,
            booking.vehicle_name,
            booking.passengers,
            booking.price,
            booking.distance_miles,
            booking.distance_text,
            booking.duration_text,
            booking.service_type,
            1 if booking.is_scheduled else 0
        ))
        
        conn.commit()
        booking_id = cursor.lastrowid
        
        # Obtener la reserva creada
        cursor.execute("SELECT * FROM vlx_bookings WHERE id = ?", (booking_id,))
        created_booking = cursor.fetchone()
        conn.close()
        
        # Convertir a diccionario
        booking_dict = dict(created_booking)
        
        return {"booking": booking_dict}
    
    except Exception as e:
        conn.close()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating booking: {str(e)}"
        )

# ==============================================================================
# ENDPOINT 3: LISTAR RESERVAS
# ==============================================================================

@router.get("/vlx/bookings")
async def get_bookings(
    user_id: int = Depends(get_current_user),
    status: Optional[str] = None,
    page: int = 1,
    page_size: int = 50
):
    """
    Obtiene todas las reservas del usuario autenticado.
    
    **Uso:**
    ```bash
    curl http://192.168.1.43:3000/api/vlx/bookings \
      -H "Authorization: Bearer <TOKEN>"
    ```
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Construir query con filtros
    query = "SELECT * FROM vlx_bookings WHERE user_id = ?"
    params = [user_id]
    
    if status:
        query += " AND status = ?"
        params.append(status)
    
    query += " ORDER BY created_at DESC LIMIT ? OFFSET ?"
    params.extend([page_size, (page - 1) * page_size])
    
    cursor.execute(query, params)
    bookings = cursor.fetchall()
    conn.close()
    
    # Convertir a lista de diccionarios
    bookings_list = [dict(booking) for booking in bookings]
    
    return {"bookings": bookings_list}

# ==============================================================================
# INSTRUCCIONES DE INSTALACIÓN
# ==============================================================================

"""
CÓMO AGREGAR ESTOS ENDPOINTS AL BACKEND:

1. Abrir el archivo principal del backend (main.py o app.py):
   📁 C:\Users\elkin\OneDrive\Desktop\app de prueba\main.py

2. Instalar dependencias necesarias (si no están):
   pip install python-jose[cryptography] passlib[bcrypt] python-multipart

3. Copiar el código de este archivo al main.py

4. Registrar el router en la app principal:
   
   app = FastAPI()
   app.include_router(router)

5. Reiniciar el servidor:
   cd "C:\Users\elkin\OneDrive\Desktop\app de prueba"
   python -m uvicorn main:app --reload --host 0.0.0.0 --port 3000

6. Verificar que funcionan:
   http://192.168.1.43:3000/docs

PRUEBA RÁPIDA:
==============

# Terminal 1: Iniciar backend
cd "C:\Users\elkin\OneDrive\Desktop\app de prueba"
python -m uvicorn main:app --reload --host 0.0.0.0 --port 3000

# Terminal 2: Probar login
curl -X POST http://192.168.1.43:3000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"chilaelkin4@gmail.com\",\"password\":\"chila123\",\"app\":\"vanelux\"}"

# Terminal 3: Probar crear reserva (copiar token del login)
curl -X POST http://192.168.1.43:3000/api/vlx/bookings ^
  -H "Authorization: Bearer <TOKEN_AQUI>" ^
  -H "Content-Type: application/json" ^
  -d "{\"pickup_address\":\"Test\",\"destination_address\":\"Test2\",\"pickup_time\":\"2025-11-28T14:00:00Z\",\"passengers\":2,\"price\":100.0}"

# Terminal 4: Listar reservas
curl http://192.168.1.43:3000/api/vlx/bookings ^
  -H "Authorization: Bearer <TOKEN_AQUI>"
"""

# ==============================================================================
# NOTA: Este archivo es solo referencia. Debes copiar el código al backend.
# ==============================================================================
