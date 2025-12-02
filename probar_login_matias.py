"""
Probar login del nuevo usuario contra el backend
"""
import requests
import json

BACKEND_URL = "http://192.168.1.43:3000"

# Credenciales del nuevo usuario
credenciales = {
    "username": "tumama@gmail.com",
    "password": "azlanzapata143@",
    "app": "vanelux"
}

print("=" * 80)
print("🧪 PROBANDO LOGIN DEL USUARIO MATIAS CHILA")
print("=" * 80)
print(f"📧 Email: {credenciales['username']}")
print(f"🔑 Password: {credenciales['password']}")
print(f"📱 App: {credenciales['app']}")
print(f"🌐 Backend: {BACKEND_URL}")
print()

try:
    print("🔄 Intentando login en el backend...")
    response = requests.post(
        f"{BACKEND_URL}/api/auth/login",
        json=credenciales,
        headers={"Content-Type": "application/json"},
        timeout=10
    )
    
    print(f"📊 Status Code: {response.status_code}")
    print()
    
    if response.status_code == 200:
        data = response.json()
        print("✅ LOGIN EXITOSO")
        print("=" * 80)
        print(f"🔑 Access Token: {data.get('access_token', 'N/A')[:50]}...")
        print(f"👤 Usuario:")
        user = data.get('user', {})
        print(f"   - ID: {user.get('id', 'N/A')}")
        print(f"   - Email: {user.get('email', 'N/A')}")
        print(f"   - Username: {user.get('username', 'N/A')}")
        print(f"   - Roles: {user.get('roles', 'N/A')}")
        print(f"   - Apps: {user.get('allowed_apps', 'N/A')}")
        print("=" * 80)
        print()
        print("✅ El usuario está correctamente configurado y puede usar la app")
    elif response.status_code == 404:
        print("❌ ENDPOINT NO ENCONTRADO")
        print("   El backend NO tiene implementado el endpoint /api/auth/login")
        print("   Necesitas implementar los endpoints (ver GUIA_IMPLEMENTACION_BACKEND.md)")
    elif response.status_code == 401:
        print("❌ CREDENCIALES INVÁLIDAS")
        print("   El usuario existe pero la contraseña es incorrecta")
        print(f"   Respuesta: {response.text}")
    else:
        print(f"❌ ERROR: {response.status_code}")
        print(f"Respuesta: {response.text}")
        
except requests.exceptions.ConnectionError:
    print("❌ NO SE PUDO CONECTAR AL BACKEND")
    print(f"   Backend URL: {BACKEND_URL}")
    print("   Verifica que el backend esté corriendo")
except requests.exceptions.Timeout:
    print("❌ TIMEOUT - El backend no respondió a tiempo")
except Exception as e:
    print(f"❌ ERROR: {e}")
    import traceback
    traceback.print_exc()
