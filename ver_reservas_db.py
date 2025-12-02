import sqlite3
import json

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print("=" * 80)
print("📋 RESERVAS EN LA BASE DE DATOS (vlx_bookings)")
print("=" * 80)

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Ver estructura de la tabla
    cursor.execute("PRAGMA table_info(vlx_bookings)")
    columns = cursor.fetchall()
    
    print("\n📊 Estructura de la tabla vlx_bookings:")
    for col in columns:
        print(f"  - {col[1]} ({col[2]})")
    
    # Listar todas las reservas
    cursor.execute("SELECT * FROM vlx_bookings ORDER BY created_at DESC")
    bookings = cursor.fetchall()
    
    print(f"\n✅ Total de reservas: {len(bookings)}")
    print("=" * 80)
    
    if bookings:
        # Obtener nombres de columnas
        column_names = [desc[0] for desc in cursor.description]
        
        for booking in bookings:
            print(f"\n📦 Reserva #{booking[0]}")
            for i, col_name in enumerate(column_names):
                value = booking[i]
                # Formatear JSON si es necesario
                if col_name in ['pickup_location', 'destination_location', 'metadata'] and value:
                    try:
                        value = json.loads(value)
                    except:
                        pass
                print(f"  {col_name}: {value}")
            print("-" * 80)
    else:
        print("\n❌ No hay reservas en la base de datos")
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
