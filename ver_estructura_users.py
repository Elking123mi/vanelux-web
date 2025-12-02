"""
Script para ver la estructura de la tabla users en Supabase
"""
import sqlite3
import os

# Ruta a la base de datos
db_path = r"C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db"

if not os.path.exists(db_path):
    print(f"❌ No se encontró la base de datos: {db_path}")
    exit(1)

print("=" * 80)
print("📋 ESTRUCTURA DE LA TABLA 'users' EN SUPABASE")
print("=" * 80)
print()

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Obtener información de las columnas
    cursor.execute("PRAGMA table_info(users)")
    columns = cursor.fetchall()
    
    print("COLUMNA".ljust(25), "TIPO".ljust(15), "RESTRICCIONES")
    print("-" * 80)
    
    for col in columns:
        col_id = col[0]
        col_name = col[1]
        col_type = col[2]
        not_null = "NOT NULL" if col[3] == 1 else ""
        default_value = f"DEFAULT {col[4]}" if col[4] is not None else ""
        pk = "PRIMARY KEY" if col[5] == 1 else ""
        
        restrictions = " ".join(filter(None, [not_null, default_value, pk]))
        
        print(f"  {col_name.ljust(23)} {col_type.ljust(15)} {restrictions}")
    
    print("-" * 80)
    print()
    
    # Contar usuarios actuales
    cursor.execute("SELECT COUNT(*) FROM users")
    count = cursor.fetchone()[0]
    print(f"📊 Total de usuarios actuales: {count}")
    print()
    
    # Mostrar un ejemplo de usuario
    print("=" * 80)
    print("📝 EJEMPLO DE USUARIO EXISTENTE:")
    print("=" * 80)
    cursor.execute("SELECT * FROM users LIMIT 1")
    example = cursor.fetchone()
    
    if example:
        cursor.execute("PRAGMA table_info(users)")
        col_names = [col[1] for col in cursor.fetchall()]
        
        for i, col_name in enumerate(col_names):
            value = example[i]
            if col_name == 'password_hash':
                value = f"{str(value)[:20]}..." if value else None
            print(f"  {col_name.ljust(20)}: {value}")
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
