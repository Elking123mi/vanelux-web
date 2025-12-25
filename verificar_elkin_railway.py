"""
Verificar si usuario existe haciendo login
"""
import requests

RAILWAY_URL = "https://web-production-700fe.up.railway.app"

print("=" * 80)
print("🔐 VERIFICANDO USUARIO EN RAILWAY")
print("=" * 80)

try:
    # Intentar login con username (Railway espera username, no email)
    login_url = f"{RAILWAY_URL}/api/v1/auth/login"
    login_data = {
        "username": "elkinjeremias123@gmail.com",  # Usar email como username
        "password": "Azlanzapata143@",  # Contraseña correcta con A mayúscula
        "app": "vanelux"
    }
    headers = {"Content-Type": "application/json"}
    
    print("🔍 Intentando login...")
    response = requests.post(login_url, json=login_data, headers=headers)
    
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print("✅ USUARIO EXISTE Y LOGIN EXITOSO!")
        print(f"    User ID: {data.get('user_id')}")
        print(f"    Email: {data.get('email')}")
        print(f"    Name: {data.get('name')}")
        if data.get('access_token'):
            print(f"    Token: {data.get('access_token')[:50]}...")
    else:
        print(f"❌ Login falló: {response.text}")

except Exception as e:
    print(f"❌ ERROR: {e}")

print()
print("=" * 80)
