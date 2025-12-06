"""
Script para verificar qué usuario está conectado en la web
y qué reservas tiene
"""

import requests

RAILWAY_URL = "https://web-production-700fe.up.railway.app"

print("="*80)
print("🔍 VERIFICANDO USUARIO Y RESERVAS")
print("="*80)

# Login con Elkin
print("\n🔐 Login como elkinjeremias123@gmail.com...")
try:
    response = requests.post(
        f"{RAILWAY_URL}/api/v1/auth/login",
        json={
            "username": "elkinjeremias123@gmail.com",
            "password": "azlanzapata143@",
            "app": "vanelux"
        },
        headers={"Content-Type": "application/json"},
        timeout=60
    )
    
    if response.status_code == 200:
        data = response.json()
        user = data.get('user', {})
        token = data.get('access_token')
        
        print(f"✅ Login exitoso")
        print(f"   👤 user_id: {user.get('id')}")
        print(f"   📧 email: {user.get('email')}")
        print(f"   📛 name: {user.get('name')}")
        print(f"   🎭 roles: {user.get('roles')}")
        
        # Obtener reservas
        print(f"\n📋 Reservas de este usuario:")
        response = requests.get(
            f"{RAILWAY_URL}/api/v1/vlx/bookings",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            timeout=60
        )
        
        if response.status_code == 200:
            bookings_data = response.json()
            bookings = bookings_data if isinstance(bookings_data, list) else bookings_data.get('bookings', [])
            
            print(f"   ✅ Total: {len(bookings)} reservas")
            print()
            
            for booking in bookings:
                print(f"   📦 Reserva #{booking.get('id')}:")
                print(f"      user_id: {booking.get('user_id')}")
                print(f"      📍 Pickup: {booking.get('pickup_address')}")
                print(f"      🎯 Destination: {booking.get('destination_address')}")
                print(f"      🚗 Vehicle: {booking.get('vehicle_name')}")
                print(f"      💰 Price: ${booking.get('price')}")
                print(f"      📅 Date: {booking.get('pickup_time')}")
                print(f"      📊 Status: {booking.get('status')}")
                print()
        else:
            print(f"   ❌ Error: {response.status_code}")
            print(f"   {response.text}")
            
except Exception as e:
    print(f"❌ Error: {e}")

print("="*80)
