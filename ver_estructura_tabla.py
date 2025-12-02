import sqlite3

# Conectar a la base de datos
db_path = r"C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Obtener información de la tabla vlx_bookings
cursor.execute("PRAGMA table_info(vlx_bookings)")
columns = cursor.fetchall()

print("📋 Estructura de la tabla vlx_bookings:")
print("-" * 60)
for col in columns:
    print(f"  {col[1]:20} {col[2]:15} {'NOT NULL' if col[3] else ''}")
print("-" * 60)

# Ver si hay alguna reserva
cursor.execute("SELECT COUNT(*) FROM vlx_bookings")
count = cursor.fetchone()[0]
print(f"\n📊 Total de reservas actuales: {count}")

conn.close()
