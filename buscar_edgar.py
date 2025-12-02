import sqlite3
import json

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print("🔍 Buscando usuario 'Edgar' en la base de datos...\n")

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Buscar en tabla 'users' (backend)
    print("📊 Tabla: users")
    cursor.execute("""
        SELECT * 
        FROM users 
        WHERE email LIKE '%edgar%' OR username LIKE '%edgar%'
    """)
    users = cursor.fetchall()
    
    if users:
        print(f"✅ Encontrados {len(users)} usuarios:\n")
        # Obtener nombres de columnas
        column_names = [description[0] for description in cursor.description]
        for user in users:
            for i, col in enumerate(column_names):
                print(f"  {col}: {user[i]}")
            print("  " + "-" * 50)
    else:
        print("❌ No se encontró ningún usuario con 'Edgar' en users")
    
    # Buscar en tabla 'vanelux_users'
    print("\n📊 Tabla: vanelux_users")
    cursor.execute("""
        SELECT * FROM vanelux_users 
        WHERE email LIKE '%edgar%' OR name LIKE '%edgar%'
    """)
    vanelux_users = cursor.fetchall()
    
    if vanelux_users:
        print(f"✅ Encontrados {len(vanelux_users)} usuarios VaneLux")
        for user in vanelux_users:
            print(f"  {user}")
    else:
        print("❌ No se encontró ningún usuario con 'Edgar' en vanelux_users")
    
    # Buscar en tabla 'clients' (por si acaso)
    print("\n📊 Tabla: clients")
    cursor.execute("""
        SELECT * FROM clients 
        WHERE name LIKE '%edgar%' OR email LIKE '%edgar%'
    """)
    clients = cursor.fetchall()
    
    if clients:
        print(f"✅ Encontrados {len(clients)} clientes")
        for client in clients:
            print(f"  {client}")
    else:
        print("❌ No se encontró ningún cliente con 'Edgar' en clients")
    
    # Mostrar total de usuarios
    print("\n" + "=" * 60)
    cursor.execute("SELECT COUNT(*) FROM users")
    total_users = cursor.fetchone()[0]
    print(f"📈 Total de usuarios en tabla 'users': {total_users}")
    
    conn.close()
    print("\n✅ Consulta completada")
    
except Exception as e:
    print(f"❌ Error: {e}")
