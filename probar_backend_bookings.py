import requests
import json

# Configuración
base_url = "http://localhost:3000/api/v1"

print("=" * 80)
print("🧪 PROBANDO ENDPOINTS DE RESERVAS")
print("=" * 80)

# 1. Login
print("\n1️⃣  Probando LOGIN...")
login_data = {
    "username": "admin",
    "password": "admin123"
}

try:
    response = requests.post(f"{base_url}/auth/login", json=login_data)
    print(f"   Status: {response.status_code}")
    
    if response.status_code == 200:
        login_result = response.json()
        token = login_result.get('access_token')
        print(f"   ✅ Token obtenido: {token[:30]}...")
    else:
        print(f"   ❌ Error: {response.text}")
        exit(1)
except Exception as e:
    print(f"   ❌ Error: {e}")
    exit(1)

# 2. Obtener reservas
print("\n2️⃣  Probando GET /vlx/bookings...")
headers = {
    "Authorization": f"Bearer {token}"
}

try:
    response = requests.get(f"{base_url}/vlx/bookings", headers=headers)
    print(f"   Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        bookings = result.get('bookings', [])
        print(f"   ✅ {len(bookings)} reservas encontradas")
        
        for i, booking in enumerate(bookings, 1):
            print(f"\n   📋 Reserva #{i}:")
            print(f"      ID: {booking.get('id')}")
            print(f"      Usuario: {booking.get('user_id')}")
            print(f"      Origen: {booking.get('pickup_address')}")
            print(f"      Destino: {booking.get('destination_address')}")
            print(f"      Precio: ${booking.get('price')}")
            print(f"      Estado: {booking.get('status')}")
    else:
        print(f"   ❌ Error: {response.text}")
        
except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n" + "=" * 80)
print("✅ PRUEBA COMPLETADA")
print("=" * 80)
print("\n💡 Si viste reservas arriba, el backend está funcionando correctamente")
print("   y VaneLux debería poder sincronizar las reservas entre dispositivos.\n")
