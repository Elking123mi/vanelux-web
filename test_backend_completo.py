"""
SCRIPT DE PRUEBA COMPLETO PARA VERIFICAR EL BACKEND
====================================================

Este script prueba los 3 endpoints:
1. POST /api/auth/login - Autenticación
2. POST /api/vlx/bookings - Crear reserva
3. GET /api/vlx/bookings - Listar reservas

Ejecutar después de implementar los endpoints en el backend.
"""

import requests
import json
from datetime import datetime

# Configuración
BASE_URL = "http://192.168.1.43:3000/api"
TEST_USER = {
    "username": "chilaelkin4@gmail.com",
    "password": "chila123",
    "app": "vanelux"
}

print("=" * 80)
print("🧪 PRUEBA COMPLETA DEL BACKEND VANELUX")
print("=" * 80)

# ==============================================================================
# TEST 1: LOGIN
# ==============================================================================
print("\n📝 TEST 1: Autenticación (POST /api/auth/login)")
print("-" * 80)

try:
    response = requests.post(
        f"{BASE_URL}/auth/login",
        json=TEST_USER,
        headers={"Content-Type": "application/json"}
    )
    
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        login_data = response.json()
        print("✅ LOGIN EXITOSO")
        print(f"📧 Usuario: {login_data['user']['email']}")
        print(f"🔑 Token: {login_data['access_token'][:50]}...")
        
        # Guardar token para siguientes pruebas
        TOKEN = login_data['access_token']
        USER_ID = login_data['user']['id']
        
    else:
        print(f"❌ LOGIN FALLÓ")
        print(f"Respuesta: {response.text}")
        exit(1)
        
except Exception as e:
    print(f"❌ ERROR: {e}")
    exit(1)

# ==============================================================================
# TEST 2: CREAR RESERVA
# ==============================================================================
print("\n📝 TEST 2: Crear Reserva (POST /api/vlx/bookings)")
print("-" * 80)

booking_data = {
    "pickup_address": "Aeropuerto Internacional Tocumen",
    "pickup_lat": 9.0714,
    "pickup_lng": -79.3834,
    "destination_address": "Hotel Miramar Plaza Panamá",
    "destination_lat": 9.0047,
    "destination_lng": -79.5047,
    "pickup_time": datetime.now().isoformat(),
    "vehicle_name": "Mercedes-Benz S-Class",
    "passengers": 3,
    "price": 125.50,
    "distance_miles": 15.2,
    "distance_text": "15.2 mi",
    "duration_text": "25 min",
    "service_type": "luxury",
    "is_scheduled": True
}

try:
    response = requests.post(
        f"{BASE_URL}/vlx/bookings",
        json=booking_data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {TOKEN}"
        }
    )
    
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        booking = response.json()
        print("✅ RESERVA CREADA EXITOSAMENTE")
        print(f"🆔 ID: {booking['booking']['id']}")
        print(f"📍 Origen: {booking['booking']['pickup_address']}")
        print(f"📍 Destino: {booking['booking']['destination_address']}")
        print(f"💰 Precio: ${booking['booking']['price']}")
        print(f"📅 Estado: {booking['booking']['status']}")
        
        BOOKING_ID = booking['booking']['id']
        
    else:
        print(f"❌ CREAR RESERVA FALLÓ")
        print(f"Respuesta: {response.text}")
        
except Exception as e:
    print(f"❌ ERROR: {e}")

# ==============================================================================
# TEST 3: LISTAR RESERVAS
# ==============================================================================
print("\n📝 TEST 3: Listar Reservas (GET /api/vlx/bookings)")
print("-" * 80)

try:
    response = requests.get(
        f"{BASE_URL}/vlx/bookings",
        headers={"Authorization": f"Bearer {TOKEN}"}
    )
    
    print(f"Status Code: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        bookings = data.get('bookings', [])
        
        print(f"✅ RESERVAS OBTENIDAS: {len(bookings)} encontradas")
        print()
        
        for idx, booking in enumerate(bookings[:5], 1):  # Mostrar solo las primeras 5
            print(f"  📦 Reserva #{idx}")
            print(f"     ID: {booking['id']}")
            print(f"     Origen: {booking['pickup_address']}")
            print(f"     Destino: {booking['destination_address']}")
            print(f"     Precio: ${booking['price']}")
            print(f"     Estado: {booking['status']}")
            print(f"     Creada: {booking['created_at']}")
            print()
        
        if len(bookings) > 5:
            print(f"  ... y {len(bookings) - 5} reservas más")
    
    else:
        print(f"❌ LISTAR RESERVAS FALLÓ")
        print(f"Respuesta: {response.text}")
        
except Exception as e:
    print(f"❌ ERROR: {e}")

# ==============================================================================
# TEST 4: VERIFICAR EN BASE DE DATOS
# ==============================================================================
print("\n📝 TEST 4: Verificar en Base de Datos SQLite")
print("-" * 80)

try:
    import sqlite3
    
    # Intentar conectar a la base de datos
    db_paths = [
        r"C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db",
        r"logistics.db",
        r"..\app de prueba\logistics.db"
    ]
    
    conn = None
    for db_path in db_paths:
        try:
            conn = sqlite3.connect(db_path)
            print(f"✅ Conectado a: {db_path}")
            break
        except:
            continue
    
    if conn:
        cursor = conn.cursor()
        cursor.execute(f"SELECT COUNT(*) FROM vlx_bookings WHERE user_id = {USER_ID}")
        count = cursor.fetchone()[0]
        
        print(f"📊 Total de reservas del usuario en DB: {count}")
        
        cursor.execute(f"""
            SELECT id, pickup_address, destination_address, price, status, created_at 
            FROM vlx_bookings 
            WHERE user_id = {USER_ID} 
            ORDER BY created_at DESC 
            LIMIT 3
        """)
        
        recent = cursor.fetchall()
        print("\n🕐 Últimas 3 reservas:")
        for row in recent:
            print(f"   • ID {row[0]}: {row[1]} → {row[2]} (${row[3]}) [{row[4]}]")
        
        conn.close()
    else:
        print("⚠️  No se pudo conectar a la base de datos (esto es normal si no está en esta carpeta)")

except Exception as e:
    print(f"⚠️  No se pudo verificar la DB: {e}")

# ==============================================================================
# RESUMEN
# ==============================================================================
print("\n" + "=" * 80)
print("📊 RESUMEN DE PRUEBAS")
print("=" * 80)
print("✅ Si todos los tests pasaron, el backend está funcionando correctamente")
print("✅ Ahora puedes probar desde la app de Flutter")
print()
print("🎯 SIGUIENTE PASO:")
print("   1. Abre la app de Flutter en Windows o Android")
print("   2. Inicia sesión con: chilaelkin4@gmail.com / chila123")
print("   3. Crea una reserva")
print("   4. Ve a 'My Bookings' y verifica que aparezca")
print("   5. Abre la app en otro dispositivo y verifica que la reserva esté sincronizada")
print("=" * 80)
