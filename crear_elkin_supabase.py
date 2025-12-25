"""
Script para crear usuario elkinjeremias123@gmail.com en Supabase
"""
import requests
import json

# Configuración de Supabase (la correcta que usa Railway)
SUPABASE_URL = "https://nbbhavrhuqzhluxmuwdo.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iYmhhdnJodXF6aGx1eG11d2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTczOTQsImV4cCI6MjA0ODIzMzM5NH0.YErk7xUkup3pE7t-XcXNP45ih2YGJxf8rLVZJCMWA6A"

# Datos del usuario
nuevo_usuario = {
    "email": "elkinjeremias123@gmail.com",
    "name": "Elkin Chila",
    "phone": "+1234567890",
}

print("=" * 80)
print("🆕 CREANDO USUARIO EN SUPABASE - vlx_passengers")
print("=" * 80)
print(f"📧 Email: {nuevo_usuario['email']}")
print(f"👤 Nombre: {nuevo_usuario['name']}")
print(f"📱 Teléfono: {nuevo_usuario['phone']}")
print()

try:
    # 1. Verificar si el usuario ya existe en vlx_passengers
    print("🔍 Verificando si el usuario ya existe...")
    
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }
    
    check_url = f"{SUPABASE_URL}/rest/v1/vlx_passengers?email=eq.{nuevo_usuario['email']}"
    response = requests.get(check_url, headers=headers)
    
    if response.status_code == 200:
        existing = response.json()
        if existing:
            print(f"⚠️  El usuario ya existe con ID: {existing[0].get('id')}")
            print(f"    Nombre: {existing[0].get('name')}")
            print(f"    Email: {existing[0].get('email')}")
            print(f"    Teléfono: {existing[0].get('phone')}")
            print()
            print("✅ No es necesario crear el usuario")
        else:
            # 2. Crear el usuario en vlx_passengers
            print("📝 Creando usuario en vlx_passengers...")
            
            create_url = f"{SUPABASE_URL}/rest/v1/vlx_passengers"
            response = requests.post(create_url, headers=headers, json=nuevo_usuario)
            
            if response.status_code in [200, 201]:
                user_data = response.json()
                print("✅ Usuario creado exitosamente!")
                if user_data:
                    print(f"    ID: {user_data[0].get('id')}")
                    print(f"    Email: {user_data[0].get('email')}")
                    print(f"    Nombre: {user_data[0].get('name')}")
            else:
                print(f"❌ Error al crear usuario: {response.status_code}")
                print(f"    Respuesta: {response.text}")
    else:
        print(f"❌ Error al verificar usuario: {response.status_code}")
        print(f"    Respuesta: {response.text}")
    
    print()
    print("=" * 80)

except Exception as e:
    print(f"❌ ERROR: {e}")
    import traceback
    traceback.print_exc()

print()
print("=" * 80)
print("✅ PROCESO COMPLETADO")
print("=" * 80)
