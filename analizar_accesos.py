import sqlite3
import json

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print("=" * 80)
print("🔐 ANÁLISIS DE ACCESOS POR APLICACIÓN")
print("=" * 80)

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute("SELECT id, username, email, roles, allowed_apps, status FROM users")
    users = cursor.fetchall()
    
    vanelux_users = []
    conexaship_users = []
    both_apps_users = []
    
    print(f"\n📊 Total de usuarios: {len(users)}\n")
    
    for user in users:
        user_id, username, email, roles, allowed_apps_str, status = user
        
        # Parsear allowed_apps (es un JSON string)
        try:
            allowed_apps = json.loads(allowed_apps_str) if allowed_apps_str else []
        except:
            allowed_apps = []
        
        print(f"👤 {username} ({email})")
        print(f"   Roles: {roles}")
        print(f"   Apps permitidas: {allowed_apps}")
        print(f"   Estado: {status}")
        
        # Clasificar accesos
        has_vanelux = 'vanelux' in allowed_apps
        has_conexaship = 'conexaship' in allowed_apps
        
        if has_vanelux and has_conexaship:
            print("   ✅ ACCESO A AMBAS: VaneLux ✓ | Conexaship ✓")
            both_apps_users.append(username)
        elif has_vanelux:
            print("   ✅ Solo VaneLux")
            vanelux_users.append(username)
        elif has_conexaship:
            print("   ✅ Solo Conexaship")
            conexaship_users.append(username)
        else:
            print("   ❌ Sin acceso a ninguna app")
        
        print("-" * 80)
    
    # Resumen
    print("\n" + "=" * 80)
    print("📈 RESUMEN DE ACCESOS")
    print("=" * 80)
    
    print(f"\n🌟 USUARIOS CON ACCESO A AMBAS APPS ({len(both_apps_users)}):")
    if both_apps_users:
        for user in both_apps_users:
            print(f"   • {user}")
    else:
        print("   (ninguno)")
    
    print(f"\n🚖 Solo VaneLux ({len(vanelux_users)}):")
    if vanelux_users:
        for user in vanelux_users:
            print(f"   • {user}")
    else:
        print("   (ninguno)")
    
    print(f"\n📦 Solo Conexaship ({len(conexaship_users)}):")
    if conexaship_users:
        for user in conexaship_users:
            print(f"   • {user}")
    else:
        print("   (ninguno)")
    
    print("\n" + "=" * 80)
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
