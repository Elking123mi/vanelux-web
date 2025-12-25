"""
Script para crear usuario elkinjeremias123@gmail.com en Supabase usando librería oficial
"""
from supabase import create_client
from passlib.context import CryptContext

# Configuración de Supabase
SUPABASE_URL = "https://nbbhavrhuqzhluxmuwdo.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iYmhhdnJodXF6aGx1eG11d2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTczOTQsImV4cCI6MjA0ODIzMzM5NH0.YErk7xUkup3pE7t-XcXNP45ih2YGJxf8rLVZJCMWA6A"

# Inicializar Supabase
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# Configurar hasher de contraseñas
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Datos del usuario
nuevo_usuario = {
    "username": "elkinjeremias123",
    "email": "elkinjeremias123@gmail.com",
    "password": "azlanzapata143@",
    "full_name": "Elkin Chila",
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
print()

try:
    # 1. Verificar si el usuario ya existe
    print("🔍 Verificando si el usuario ya existe...")
    existing = supabase.table('users').select('*').eq('email', nuevo_usuario['email']).execute()
    
    if existing.data:
        print(f"⚠️  El usuario ya existe:")
        user = existing.data[0]
        print(f"    ID: {user.get('id')}")
        print(f"    Email: {user.get('email')}")
        print(f"    Username: {user.get('username')}")
        print(f"    Status: {user.get('status')}")
        print(f"    Allowed Apps: {user.get('allowed_apps')}")
        print()
        print("✅ Usuario ya configurado correctamente")
    else:
        # 2. Crear el usuario
        print("📝 Creando usuario en Supabase...")
        
        # Hash de la contraseña
        hashed_password = pwd_context.hash(nuevo_usuario['password'])
        
        user_data = {
            "username": nuevo_usuario['username'],
            "email": nuevo_usuario['email'],
            "password_hash": hashed_password,
            "full_name": nuevo_usuario['full_name'],
            "roles": nuevo_usuario['roles'],
            "allowed_apps": nuevo_usuario['allowed_apps'],
            "status": nuevo_usuario['status']
        }
        
        result = supabase.table('users').insert(user_data).execute()
        
        if result.data:
            print("✅ USUARIO CREADO EXITOSAMENTE!")
            print(f"    ID: {result.data[0].get('id')}")
            print(f"    Email: {result.data[0].get('email')}")
            print(f"    Username: {result.data[0].get('username')}")
        else:
            print("❌ Error al crear usuario")

except Exception as e:
    print(f"❌ ERROR: {e}")
    import traceback
    traceback.print_exc()

print()
print("=" * 80)
print("✅ PROCESO COMPLETADO")
print("=" * 80)
