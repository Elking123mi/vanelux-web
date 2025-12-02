"""
Script para crear usuario directamente en Supabase usando la API REST
"""
import requests
import bcrypt
import json

# Configuración de Supabase
SUPABASE_URL = "https://nbbhavrhuqzhluxmuwdo.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iYmhhdnJodXF6aGx1eG11d2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTczOTQsImV4cCI6MjA0ODIzMzM5NH0.YErk7xUkup3pE7t-XcXNP45ih2YGJxf8rLVZJCMWA6A"

# Datos del nuevo usuario
nuevo_usuario = {
    "username": "tumama@gmail.com",
    "email": "tumama@gmail.com",
    "password": "azlanzapata143@",
    "full_name": "Matias Chila",
    "roles": ["passenger"],
    "allowed_apps": ["vanelux", "conexaship"],
    "status": "active"
}

print("=" * 80)
print("🆕 CREANDO USUARIO EN SUPABASE")
print("=" * 80)
print(f"📧 Email: {nuevo_usuario['email']}")
print(f"👤 Nombre: {nuevo_usuario['full_name']}")
print(f"🔑 Password: {nuevo_usuario['password']}")
print(f"📱 Apps: {', '.join(nuevo_usuario['allowed_apps'])}")
print(f"👥 Roles: {', '.join(nuevo_usuario['roles'])}")
print()

try:
    # 1. Verificar si el usuario ya existe
    print("🔍 Verificando si el usuario ya existe en Supabase...")
    
    headers = {
        "apikey": SUPABASE_ANON_KEY,
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }
    
    check_url = f"{SUPABASE_URL}/rest/v1/users?email=eq.{nuevo_usuario['email']}"
    response = requests.get(check_url, headers=headers)
    
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        existing = response.json()
        
        if existing and len(existing) > 0:
            print(f"⚠️  El usuario ya existe en Supabase:")
            print(f"   ID: {existing[0]['id']}")
            print(f"   Email: {existing[0]['email']}")
            print(f"   Username: {existing[0]['username']}")
            print()
            
            respuesta = input("¿Deseas actualizar la contraseña? (s/n): ")
            
            if respuesta.lower() != 's':
                print("❌ Operación cancelada")
                exit(0)
            
            # Hashear nueva contraseña
            print("🔐 Hasheando contraseña...")
            password_bytes = nuevo_usuario['password'].encode('utf-8')
            salt = bcrypt.gensalt()
            password_hash = bcrypt.hashpw(password_bytes, salt).decode('utf-8')
            
            # Actualizar usuario
            update_url = f"{SUPABASE_URL}/rest/v1/users?id=eq.{existing[0]['id']}"
            update_data = {
                "password_hash": password_hash,
                "full_name": nuevo_usuario['full_name'],
                "roles": json.dumps(nuevo_usuario['roles']),
                "allowed_apps": json.dumps(nuevo_usuario['allowed_apps'])
            }
            
            print("💾 Actualizando usuario en Supabase...")
            update_response = requests.patch(update_url, json=update_data, headers=headers)
            
            if update_response.status_code in [200, 204]:
                print("✅ Usuario actualizado exitosamente en Supabase")
            else:
                print(f"❌ Error al actualizar: {update_response.status_code}")
                print(f"Respuesta: {update_response.text}")
        else:
            # Usuario no existe, crear uno nuevo
            print("✅ El email está disponible en Supabase")
            
            # Hashear contraseña
            print("🔐 Hasheando contraseña...")
            password_bytes = nuevo_usuario['password'].encode('utf-8')
            salt = bcrypt.gensalt()
            password_hash = bcrypt.hashpw(password_bytes, salt).decode('utf-8')
            
            # Preparar datos
            user_data = {
                "username": nuevo_usuario['username'],
                "email": nuevo_usuario['email'],
                "password_hash": password_hash,
                "full_name": nuevo_usuario['full_name'],
                "roles": json.dumps(nuevo_usuario['roles']),
                "allowed_apps": json.dumps(nuevo_usuario['allowed_apps']),
                "status": nuevo_usuario['status']
            }
            
            # Insertar en Supabase
            print("💾 Insertando usuario en Supabase...")
            insert_url = f"{SUPABASE_URL}/rest/v1/users"
            insert_response = requests.post(insert_url, json=user_data, headers=headers)
            
            print(f"Status: {insert_response.status_code}")
            
            if insert_response.status_code in [200, 201]:
                created = insert_response.json()
                if created and len(created) > 0:
                    user = created[0]
                    print()
                    print("=" * 80)
                    print("✅ USUARIO CREADO EXITOSAMENTE EN SUPABASE")
                    print("=" * 80)
                    print(f"🆔 ID: {user.get('id', 'N/A')}")
                    print(f"📧 Email: {user.get('email', 'N/A')}")
                    print(f"👤 Username: {user.get('username', 'N/A')}")
                    print(f"👥 Nombre completo: {user.get('full_name', 'N/A')}")
                    print(f"📱 Apps permitidas: {user.get('allowed_apps', 'N/A')}")
                    print(f"👔 Roles: {user.get('roles', 'N/A')}")
                    print(f"✅ Estado: {user.get('status', 'N/A')}")
                    print()
                    print("=" * 80)
                    print("🎯 CREDENCIALES PARA INICIAR SESIÓN")
                    print("=" * 80)
                    print(f"📧 Email: {nuevo_usuario['email']}")
                    print(f"🔑 Password: {nuevo_usuario['password']}")
                    print(f"📱 App: vanelux")
                    print("=" * 80)
                else:
                    print("✅ Usuario creado pero no se recibió confirmación detallada")
            else:
                print(f"❌ Error al crear usuario: {insert_response.status_code}")
                print(f"Respuesta: {insert_response.text}")
    else:
        print(f"❌ Error al verificar usuario: {response.status_code}")
        print(f"Respuesta: {response.text}")
        
    # Verificar el usuario
    print()
    print("🔍 Verificando usuario en Supabase...")
    verify_url = f"{SUPABASE_URL}/rest/v1/users?email=eq.{nuevo_usuario['email']}"
    verify_response = requests.get(verify_url, headers=headers)
    
    if verify_response.status_code == 200:
        users = verify_response.json()
        if users and len(users) > 0:
            print("✅ Usuario verificado en Supabase:")
            print(f"   ID: {users[0].get('id', 'N/A')}")
            print(f"   Email: {users[0].get('email', 'N/A')}")
            print(f"   Nombre: {users[0].get('full_name', 'N/A')}")
            print(f"   Estado: {users[0].get('status', 'N/A')}")
        else:
            print("⚠️  Usuario no encontrado después de la creación")
    
except Exception as e:
    print()
    print("=" * 80)
    print("❌ ERROR AL CREAR USUARIO EN SUPABASE")
    print("=" * 80)
    print(f"Error: {str(e)}")
    print()
    import traceback
    traceback.print_exc()
