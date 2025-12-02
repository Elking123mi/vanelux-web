import sqlite3

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print("=" * 70)
print("📊 TODOS LOS USUARIOS EN LA BASE DE DATOS")
print("=" * 70)

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Listar todos los usuarios
    cursor.execute("SELECT id, username, email, roles, allowed_apps, status FROM users")
    users = cursor.fetchall()
    
    print(f"\n✅ Total de usuarios: {len(users)}\n")
    
    edgar_found = False
    for user in users:
        user_id, username, email, roles, allowed_apps, status = user
        print(f"ID: {user_id}")
        print(f"  Username: {username}")
        print(f"  Email: {email}")
        print(f"  Roles: {roles}")
        print(f"  Allowed Apps: {allowed_apps}")
        print(f"  Status: {status}")
        print("-" * 70)
        
        # Buscar Edgar
        if username and 'edgar' in username.lower():
            edgar_found = True
            print("  ⭐ ¡EDGAR ENCONTRADO!")
        if email and 'edgar' in email.lower():
            edgar_found = True
            print("  ⭐ ¡EDGAR ENCONTRADO!")
    
    print("\n" + "=" * 70)
    if edgar_found:
        print("✅ SE ENCONTRÓ A EDGAR")
    else:
        print("❌ EDGAR NO EXISTE EN LA BASE DE DATOS")
    print("=" * 70)
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
