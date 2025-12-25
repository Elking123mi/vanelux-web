"""
Crear usuario via Railway backend
"""
import requests
import json

RAILWAY_URL = "https://web-production-700fe.up.railway.app"

nuevo_usuario = {
    "username": "elkinjeremias123",
    "email": "elkinjeremias123@gmail.com",
    "password": "azlanzapata143@",
    "full_name": "Elkin Chila",
    "phone": "+1234567890"
}

print("=" * 80)
print("🚀 CREANDO USUARIO VIA RAILWAY BACKEND")
print("=" * 80)
print(f"📧 Email: {nuevo_usuario['email']}")
print(f"👤 Nombre: {nuevo_usuario['full_name']}")
print(f"🔑 Password: {nuevo_usuario['password']}")
print()

try:
    # Registrar usuario
    print("📝 Registrando usuario...")
    url = f"{RAILWAY_URL}/api/v1/auth/register"
    headers = {"Content-Type": "application/json"}
    
    response = requests.post(url, json=nuevo_usuario, headers=headers)
    
    print(f"Status: {response.status_code}")
    
    if response.status_code in [200, 201]:
        data = response.json()
        print("✅ Usuario creado exitosamente!")
        print(f"    User ID: {data.get('user_id')}")
        print(f"    Email: {data.get('email')}")
        print(f"    Nombre: {data.get('name')}")
    elif response.status_code == 400:
        error = response.json()
        if "already exists" in str(error).lower():
            print("⚠️  El usuario ya existe!")
            print("✅ Intentando hacer login...")
            
            # Intentar login
            login_url = f"{RAILWAY_URL}/api/v1/auth/login"
            login_data = {
                "email": nuevo_usuario['email'],
                "password": nuevo_usuario['password']
            }
            response = requests.post(login_url, json=login_data, headers=headers)
            
            if response.status_code == 200:
                data = response.json()
                print("✅ Login exitoso!")
                print(f"    User ID: {data.get('user_id')}")
                print(f"    Email: {data.get('email')}")
            else:
                print(f"❌ Error en login: {response.text}")
        else:
            print(f"❌ Error: {error}")
    else:
        print(f"❌ Error: {response.status_code}")
        print(f"    Respuesta: {response.text}")

except Exception as e:
    print(f"❌ ERROR: {e}")

print()
print("=" * 80)
