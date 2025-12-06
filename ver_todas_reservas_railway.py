"""
Script para ver TODAS las reservas en Railway (sin filtrar por usuario)
"""

import requests

RAILWAY_URL = "https://web-production-700fe.up.railway.app"

print("="*80)
print("📋 TODAS LAS RESERVAS EN RAILWAY/SUPABASE")
print("="*80)

# Login con Elkin para obtener token
print("\n🔐 Login...")
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
        token = data.get('access_token')
        user = data.get('user', {})
        print(f"✅ Login exitoso - user_id: {user.get('id')}, email: {user.get('email')}")
        
        # Obtener TODAS las reservas del backend
        print(f"\n📋 Obteniendo reservas del usuario...")
        try:
            bookings_url = f"{RAILWAY_URL}/api/v1/vlx/bookings"
            response = requests.get(
                bookings_url,
                headers={
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json"
                },
                timeout=60
            )
            
            print(f"   Status: {response.status_code}")
            if response.status_code == 200:
                bookings_data = response.json()
                bookings = bookings_data if isinstance(bookings_data, list) else bookings_data.get('bookings', [])
                print(f"   Total: {len(bookings)} reservas\n")
                
                for i, booking in enumerate(bookings, 1):
                    print(f"   📦 Reserva #{booking.get('id')}:")
                    print(f"      user_id: {booking.get('user_id')}")
                    print(f"      pickup: {booking.get('pickup_address')}")
                    print(f"      destination: {booking.get('destination_address')}")
                    print(f"      vehicle: {booking.get('vehicle_name')}")
                    print(f"      price: ${booking.get('price')}")
                    print(f"      created_at: {booking.get('created_at')}")
                    print()
            else:
                print(f"   ⚠️  Respuesta: {response.text}")
        except Exception as e:
            print(f"   ❌ Error: {e}")
    else:
        print(f"❌ Login falló: {response.status_code}")
        
except Exception as e:
    print(f"❌ Error: {e}")

print("="*80)
