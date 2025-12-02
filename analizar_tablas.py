import sqlite3

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print("🔍 Analizando estructura de tablas relevantes...\n")

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Ver estructura de tabla 'users'
    print("=" * 60)
    print("📋 Estructura de tabla: users")
    print("=" * 60)
    cursor.execute("PRAGMA table_info(users)")
    columns = cursor.fetchall()
    for col in columns:
        print(f"  {col[1]} ({col[2]})")
    
    # Buscar Edgar en users
    print("\n🔍 Buscando 'edgar' en tabla users...")
    cursor.execute("SELECT * FROM users")
    all_users = cursor.fetchall()
    
    edgar_found = False
    for user in all_users:
        user_str = str(user).lower()
        if 'edgar' in user_str:
            print(f"\n✅ ENCONTRADO: {user}")
            edgar_found = True
    
    if not edgar_found:
        print(f"❌ No encontrado. Total usuarios: {len(all_users)}")
        if all_users:
            print(f"Ejemplo de usuario: {all_users[0]}")
    
    # Ver estructura de tabla 'vanelux_users'
    print("\n" + "=" * 60)
    print("📋 Estructura de tabla: vanelux_users")
    print("=" * 60)
    cursor.execute("PRAGMA table_info(vanelux_users)")
    columns = cursor.fetchall()
    for col in columns:
        print(f"  {col[1]} ({col[2]})")
    
    # Buscar Edgar en vanelux_users
    print("\n🔍 Buscando 'edgar' en tabla vanelux_users...")
    cursor.execute("SELECT * FROM vanelux_users")
    all_vanelux = cursor.fetchall()
    
    edgar_found = False
    for user in all_vanelux:
        user_str = str(user).lower()
        if 'edgar' in user_str:
            print(f"\n✅ ENCONTRADO: {user}")
            edgar_found = True
    
    if not edgar_found:
        print(f"❌ No encontrado. Total usuarios: {len(all_vanelux)}")
        if all_vanelux:
            print(f"Ejemplo de usuario: {all_vanelux[0]}")
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
