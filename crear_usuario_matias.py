"""
Script para crear nuevo usuario pasajero: Matias Chila
"""
import os
from supabase import create_client
from passlib.context import CryptContext
import json

# Configuración de Supabase
SUPABASE_URL = "https://nbbhavrhuqzhluxmuwdo.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iYmhhdnJodXF6aGx1eG11d2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTczOTQsImV4cCI6MjA0ODIzMzM5NH0.YErk7xUkup3pE7t-XcXNP45ih2YGJxf8rLVZJCMWA6A"

# Inicializar Supabase
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# Configurar hasher de contraseñas
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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
print("🆕 CREANDO NUEVO USUARIO PASAJERO")
print("=" * 80)
print(f"📧 Email: {nuevo_usuario['email']}")
print(f"👤 Nombre: {nuevo_usuario['full_name']}")
print(f"🔑 Password: {nuevo_usuario['password']}")
print(f"📱 Apps: {', '.join(nuevo_usuario['allowed_apps'])}")
print(f"👥 Roles: {', '.join(nuevo_usuario['roles'])}")
print()

try:
    # Verificar si el usuario ya existe
    print("🔍 Verificando si el usuario ya existe...")
    existing = supabase.table('users').select('*').eq('email', nuevo_usuario['email']).execute()
    
    if existing.data and len(existing.data) > 0:
        print(f"⚠️  El usuario con email {nuevo_usuario['email']} ya existe")
        print(f"   ID: {existing.data[0]['id']}")
        print(f"   Username: {existing.data[0]['username']}")
        print()
        respuesta = input("¿Deseas actualizar la contraseña? (s/n): ")
        
        if respuesta.lower() == 's':
            # Hashear nueva contraseña
            password_hash = pwd_context.hash(nuevo_usuario['password'])
            
            # Actualizar usuario
            result = supabase.table('users').update({
                'password_hash': password_hash,
                'full_name': nuevo_usuario['full_name']
            }).eq('email', nuevo_usuario['email']).execute()
            
            print("✅ Contraseña actualizada exitosamente")
        else:
            print("❌ Operación cancelada")
    else:
        print("✅ El email está disponible")
        
        # Hashear la contraseña
        print("🔐 Hasheando contraseña...")
        password_hash = pwd_context.hash(nuevo_usuario['password'])
        
        # Preparar datos para insertar
        user_data = {
            'username': nuevo_usuario['username'],
            'email': nuevo_usuario['email'],
            'password_hash': password_hash,
            'full_name': nuevo_usuario['full_name'],
            'roles': json.dumps(nuevo_usuario['roles']),
            'allowed_apps': json.dumps(nuevo_usuario['allowed_apps']),
            'status': nuevo_usuario['status']
        }
        
        # Insertar en la base de datos
        print("💾 Insertando usuario en la base de datos...")
        result = supabase.table('users').insert(user_data).execute()
        
        if result.data and len(result.data) > 0:
            user_created = result.data[0]
            print()
            print("=" * 80)
            print("✅ USUARIO CREADO EXITOSAMENTE")
            print("=" * 80)
            print(f"🆔 ID: {user_created['id']}")
            print(f"📧 Email: {user_created['email']}")
            print(f"👤 Username: {user_created['username']}")
            print(f"👥 Nombre completo: {user_created['full_name']}")
            print(f"📱 Apps permitidas: {user_created['allowed_apps']}")
            print(f"👔 Roles: {user_created['roles']}")
            print(f"✅ Estado: {user_created['status']}")
            print()
            print("=" * 80)
            print("🎯 CREDENCIALES PARA INICIAR SESIÓN")
            print("=" * 80)
            print(f"📧 Email: {nuevo_usuario['email']}")
            print(f"🔑 Password: {nuevo_usuario['password']}")
            print(f"📱 App: vanelux")
            print("=" * 80)
        else:
            print("❌ Error: No se recibió confirmación de la creación")
            
except Exception as e:
    print()
    print("=" * 80)
    print("❌ ERROR AL CREAR USUARIO")
    print("=" * 80)
    print(f"Error: {str(e)}")
    print()
    import traceback
    traceback.print_exc()
