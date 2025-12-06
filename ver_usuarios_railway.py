"""
Script para ver todos los usuarios en Railway
"""

import requests

RAILWAY_URL = "https://web-production-700fe.up.railway.app"
LOGIN_URL = f"{RAILWAY_URL}/api/v1/auth/login"

print("="*80)
print("👥 USUARIOS EN RAILWAY")
print("="*80)

# Login con Elkin para obtener token
print("\n🔐 Login como elkinjeremias123@gmail.com...")
try:
    response = requests.post(
        LOGIN_URL,
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
        print(f"✅ Login exitoso")
        print(f"   user_id: {user.get('id')}")
        print(f"   name: {user.get('name')}")
        print(f"   email: {user.get('email')}")
        print(f"   roles: {user.get('roles')}")
        
        # Obtener reservas de este usuario
        token = data.get('access_token')
        if token:
            print(f"\n📋 Reservas de {user.get('email')}:")
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
                
                if response.status_code == 200:
                    bookings_data = response.json()
                    bookings = bookings_data if isinstance(bookings_data, list) else bookings_data.get('bookings', [])
                    print(f"   Total: {len(bookings)} reservas")
                    for booking in bookings:
                        print(f"   - Reserva #{booking.get('id')}: {booking.get('pickup_address')} → {booking.get('destination_address')}")
                else:
                    print(f"   ⚠️  Status: {response.status_code}")
                    print(f"   {response.text}")
            except Exception as e:
                print(f"   ❌ Error: {e}")
    else:
        print(f"❌ Login falló: {response.status_code}")
        print(f"   {response.text}")
        
except Exception as e:
    print(f"❌ Error: {e}")

print("\n" + "="*80)
