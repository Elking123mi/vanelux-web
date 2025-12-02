import sqlite3
import json
from datetime import datetime

db_path = r'C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db'

print("=" * 80)
print("🔄 MONITOREO DE RESERVAS EN TIEMPO REAL")
print("=" * 80)
print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print()

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Contar reservas
    cursor.execute("SELECT COUNT(*) FROM vlx_bookings")
    total = cursor.fetchone()[0]
    
    print(f"📊 Total de reservas: {total}")
    print("=" * 80)
    
    if total > 0:
        # Mostrar todas las reservas
        cursor.execute("""
            SELECT 
                b.id,
                b.user_id,
                u.email,
                b.pickup_address,
                b.destination_address,
                b.pickup_time,
                b.vehicle_name,
                b.passengers,
                b.price,
                b.distance_text,
                b.duration_text,
                b.status,
                b.created_at
            FROM vlx_bookings b
            LEFT JOIN users u ON b.user_id = u.id
            ORDER BY b.created_at DESC
        """)
        
        bookings = cursor.fetchall()
        
        for booking in bookings:
            b_id, user_id, email, origin, dest, pickup, vehicle, passengers, price, distance, duration, status, created = booking
            
            print(f"\n🎫 Reserva #{b_id}")
            print(f"   👤 Usuario: {email} (ID: {user_id})")
            print(f"   📍 Origen: {origin}")
            print(f"   🎯 Destino: {dest}")
            print(f"   🕐 Pickup: {pickup}")
            print(f"   � Vehículo: {vehicle}")
            print(f"   �👥 Pasajeros: {passengers}")
            print(f"   💰 Precio: ${price:,.0f} COP")
            print(f"   📏 Distancia: {distance}")
            print(f"   ⏱️  Duración: {duration}")
            print(f"   📌 Estado: {status}")
            print(f"   🕒 Creada: {created}")
            print("-" * 80)
    else:
        print("\n⚠️  No hay reservas todavía")
        print("\n💡 Pasos para probar:")
        print("   1. Ejecuta la app en el emulador/chrome/windows")
        print("   2. Haz login con: ampueroelkin@gmail.com")
        print("   3. Crea una reserva desde la pantalla principal")
        print("   4. Vuelve a ejecutar este script para ver la reserva")
    
    conn.close()
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()

print("\n" + "=" * 80)
print("✅ Para monitorear continuamente, ejecuta este script después de cada reserva")
print("=" * 80)
