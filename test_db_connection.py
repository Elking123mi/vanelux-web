import sqlite3
import os

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print(f"🔍 Verificando ruta: {db_path}")
print(f"📁 ¿Archivo existe? {os.path.exists(db_path)}")

if os.path.exists(db_path):
    try:
        conn = sqlite3.connect(db_path)
        print("✅ Conexión exitosa a logistics.db")
        
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
        tables = cursor.fetchall()
        
        print(f"\n📋 Tablas disponibles ({len(tables)}):")
        for table in tables:
            print(f"  - {table[0]}")
        
        conn.close()
        print("\n✅ Puedo conectarme sin problemas")
        
    except Exception as e:
        print(f"❌ Error: {e}")
else:
    print("❌ La base de datos no existe en esa ruta")
