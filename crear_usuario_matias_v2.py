"""
Script para crear nuevo usuario pasajero: Matias Chila
Usando el backend local en lugar de Supabase directamente
"""
import requests
import json

# Configuración
BACKEND_URL = "http://192.168.1.43:3000"

# Datos del nuevo usuario
nuevo_usuario = {
    "username": "tumama@gmail.com",
    "email": "tumama@gmail.com",
    "password": "azlanzapata143@",
    "full_name": "Matias Chila",
    "phone": "+507 6000-0000",  # Teléfono de ejemplo
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

# Como el backend no tiene endpoint de registro, vamos a insertar directamente en la BD
# usando el mismo método que los otros scripts Python
import sqlite3
from passlib.context import CryptContext

# Buscar la base de datos
import os

# Posibles ubicaciones de la base de datos
db_paths = [
    r"C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db",
    r"C:\Users\elkin\OneDrive\Desktop\app de prueba\backend\logistics.db",
    r"C:\Users\elkin\OneDrive\Desktop\app de prueba\database\logistics.db",
]

db_path = None
for path in db_paths:
    if os.path.exists(path):
        db_path = path
        break

if not db_path:
    print("❌ No se encontró la base de datos logistics.db")
    print("   Buscado en:")
    for path in db_paths:
        print(f"   - {path}")
    print()
    print("Por favor, ingresa la ruta completa a logistics.db:")
    db_path = input("> ").strip()
    
    if not os.path.exists(db_path):
        print("❌ La ruta proporcionada no existe")
        exit(1)

print(f"✅ Base de datos encontrada: {db_path}")
print()

try:
    # Conectar a la base de datos
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    # Verificar si el usuario ya existe
    print("🔍 Verificando si el usuario ya existe...")
    cursor.execute("""
        SELECT id, username, email, full_name, status 
        FROM users 
        WHERE email = ? OR username = ?
    """, (nuevo_usuario['email'], nuevo_usuario['username']))
    
    existing = cursor.fetchone()
    
    if existing:
        print(f"⚠️  El usuario ya existe:")
        print(f"   ID: {existing['id']}")
        print(f"   Username: {existing['username']}")
        print(f"   Email: {existing['email']}")
        print(f"   Nombre: {existing['full_name']}")
        print(f"   Estado: {existing['status']}")
        print()
        
        respuesta = input("¿Deseas actualizar la contraseña y datos? (s/n): ")
        
        if respuesta.lower() == 's':
            # Hashear nueva contraseña
            pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
            password_hash = pwd_context.hash(nuevo_usuario['password'])
            
            # Actualizar usuario
            cursor.execute("""
                UPDATE users 
                SET password_hash = ?,
                    full_name = ?,
                    phone = ?,
                    roles = ?,
                    allowed_apps = ?
                WHERE email = ?
            """, (
                password_hash,
                nuevo_usuario['full_name'],
                nuevo_usuario.get('phone', ''),
                json.dumps(nuevo_usuario['roles']),
                json.dumps(nuevo_usuario['allowed_apps']),
                nuevo_usuario['email']
            ))
            
            conn.commit()
            print("✅ Usuario actualizado exitosamente")
            print()
            print("=" * 80)
            print("🎯 CREDENCIALES ACTUALIZADAS")
            print("=" * 80)
            print(f"📧 Email: {nuevo_usuario['email']}")
            print(f"🔑 Password: {nuevo_usuario['password']}")
            print(f"📱 App: vanelux")
            print("=" * 80)
        else:
            print("❌ Operación cancelada")
    else:
        print("✅ El email está disponible")
        
        # Hashear la contraseña
        print("🔐 Hasheando contraseña...")
        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        # Bcrypt tiene un límite de 72 bytes
        password_to_hash = nuevo_usuario['password'][:72]
        password_hash = pwd_context.hash(password_to_hash)
        
        # Insertar en la base de datos
        print("💾 Insertando usuario en la base de datos...")
        cursor.execute("""
            INSERT INTO users (
                username, 
                email, 
                password_hash, 
                full_name, 
                phone,
                roles, 
                allowed_apps, 
                status,
                created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
        """, (
            nuevo_usuario['username'],
            nuevo_usuario['email'],
            password_hash,
            nuevo_usuario['full_name'],
            nuevo_usuario.get('phone', ''),
            json.dumps(nuevo_usuario['roles']),
            json.dumps(nuevo_usuario['allowed_apps']),
            nuevo_usuario['status']
        ))
        
        conn.commit()
        user_id = cursor.lastrowid
        
        print()
        print("=" * 80)
        print("✅ USUARIO CREADO EXITOSAMENTE")
        print("=" * 80)
        print(f"🆔 ID: {user_id}")
        print(f"📧 Email: {nuevo_usuario['email']}")
        print(f"👤 Username: {nuevo_usuario['username']}")
        print(f"👥 Nombre completo: {nuevo_usuario['full_name']}")
        print(f"📞 Teléfono: {nuevo_usuario.get('phone', 'N/A')}")
        print(f"📱 Apps permitidas: {', '.join(nuevo_usuario['allowed_apps'])}")
        print(f"👔 Roles: {', '.join(nuevo_usuario['roles'])}")
        print(f"✅ Estado: {nuevo_usuario['status']}")
        print()
        print("=" * 80)
        print("🎯 CREDENCIALES PARA INICIAR SESIÓN")
        print("=" * 80)
        print(f"📧 Email: {nuevo_usuario['email']}")
        print(f"🔑 Password: {nuevo_usuario['password']}")
        print(f"📱 App: vanelux")
        print("=" * 80)
    
    conn.close()
    
    # Verificar que se creó correctamente
    print()
    print("🔍 Verificando en la base de datos...")
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT id, username, email, full_name, roles, allowed_apps, status 
        FROM users 
        WHERE email = ?
    """, (nuevo_usuario['email'],))
    
    verificacion = cursor.fetchone()
    
    if verificacion:
        print("✅ Usuario verificado en la base de datos:")
        print(f"   ID: {verificacion['id']}")
        print(f"   Email: {verificacion['email']}")
        print(f"   Nombre: {verificacion['full_name']}")
        print(f"   Estado: {verificacion['status']}")
    
    conn.close()
    
except Exception as e:
    print()
    print("=" * 80)
    print("❌ ERROR AL CREAR USUARIO")
    print("=" * 80)
    print(f"Error: {str(e)}")
    print()
    import traceback
    traceback.print_exc()
    
    if 'conn' in locals():
        conn.close()
