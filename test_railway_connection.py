#!/usr/bin/env python3
"""
Script para probar la conexión con el backend de Railway
"""
import requests
import json

# URL del backend en Railway
BASE_URL = "https://web-production-700fe.up.railway.app/api/v1"

def test_connection():
    """Prueba la conexión básica al backend"""
    print("🔍 Probando conexión al backend...")
    try:
        response = requests.get("https://web-production-700fe.up.railway.app/")
        print(f"✅ Backend respondió: {response.status_code}")
        print(f"📦 Respuesta: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        return False

def test_login(email, password, app="vanelux"):
    """Prueba el login con credenciales"""
    print(f"\n🔐 Probando login con {email}...")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            json={
                "username": email,
                "password": password,
                "app": app
            },
            headers={"Content-Type": "application/json"}
        )
        
        print(f"📊 Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Login exitoso!")
            print(f"👤 Usuario: {data.get('user', {}).get('full_name', 'N/A')}")
            print(f"📧 Email: {data.get('user', {}).get('email', 'N/A')}")
            print(f"🎭 Roles: {data.get('user', {}).get('roles', [])}")
            print(f"📱 Apps permitidas: {data.get('user', {}).get('allowed_apps', [])}")
            print(f"🔑 Access Token (primeros 50 chars): {data.get('access_token', '')[:50]}...")
            return data
        else:
            print(f"❌ Login falló")
            print(f"📄 Respuesta: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error en login: {e}")
        return None

def test_users():
    """Lista todos los usuarios (necesita autenticación)"""
    print(f"\n👥 Listando usuarios...")
    # Primero hacer login como admin
    admin_data = test_login("admin@example.com", "admin123", "vanelux")
    
    if not admin_data:
        print("❌ No se pudo obtener token de admin")
        return
    
    token = admin_data.get('access_token')
    
    try:
        response = requests.get(
            f"{BASE_URL}/users",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            users = data.get('users', data.get('results', []))
            print(f"✅ Encontrados {len(users)} usuarios:")
            for user in users:
                print(f"  - {user.get('full_name')} ({user.get('email')})")
                print(f"    Apps: {user.get('allowed_apps', [])}")
        else:
            print(f"❌ Error al obtener usuarios: {response.status_code}")
            print(f"📄 Respuesta: {response.text}")
            
    except Exception as e:
        print(f"❌ Error al listar usuarios: {e}")

def main():
    print("=" * 60)
    print("🚀 TEST DE CONEXIÓN - VANELUX → RAILWAY")
    print("=" * 60)
    
    # 1. Probar conexión básica
    if not test_connection():
        print("\n❌ No se puede conectar al backend. Verifica tu internet.")
        return
    
    # 2. Probar usuarios de VaneLux
    print("\n" + "=" * 60)
    print("📱 USUARIOS DE VANELUX")
    print("=" * 60)
    
    vanelux_users = [
        ("elkinjeremias123@gmail.com", "azlanzapata143@"),
        ("ampueroelkin@gmail.com", "password123"),
        ("chilaelkin4@gmail.com", "chila123"),
        ("admin@example.com", "admin123"),
    ]
    
    successful_logins = []
    
    for email, password in vanelux_users:
        result = test_login(email, password, "vanelux")
        if result:
            successful_logins.append((email, result))
    
    # 3. Resumen
    print("\n" + "=" * 60)
    print("📊 RESUMEN")
    print("=" * 60)
    print(f"✅ Logins exitosos: {len(successful_logins)}/{len(vanelux_users)}")
    
    if successful_logins:
        print("\n✅ Usuarios con acceso a VaneLux:")
        for email, data in successful_logins:
            user = data.get('user', {})
            print(f"  - {user.get('full_name', 'N/A')} ({email})")
    
    # 4. Listar todos los usuarios
    print("\n" + "=" * 60)
    print("👥 TODOS LOS USUARIOS EN EL SISTEMA")
    print("=" * 60)
    test_users()

if __name__ == "__main__":
    main()
