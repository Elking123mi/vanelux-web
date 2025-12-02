import sqlite3
from datetime import datetime, timedelta

# Conectar a la base de datos
db_path = r"C:\Users\elkin\OneDrive\Desktop\app de prueba\logistics.db"
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Datos del usuario existente
user_id = 2  # ampueroelkin@gmail.com
user_email = "ampueroelkin@gmail.com"

# Crear reserva de prueba
pickup_time = (datetime.now() + timedelta(hours=2)).strftime("%Y-%m-%d %H:%M:%S")
created_at = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

booking_data = {
    'user_id': user_id,
    'pickup_address': 'Aeropuerto El Dorado, Bogotá',
    'pickup_lat': 4.7016,
    'pickup_lng': -74.1469,
    'destination_address': 'Hotel Tequendama, Carrera 10 #26-21, Bogotá',
    'destination_lat': 4.5981,
    'destination_lng': -74.0758,
    'pickup_time': pickup_time,
    'vehicle_name': 'Mercedes-Benz Clase E',
    'passengers': 2,
    'price': 85000.00,  # $85,000 COP
    'distance_miles': 8.5,
    'distance_text': '8.5 km',
    'duration_text': '25 min',
    'service_type': 'luxury',
    'is_scheduled': 1,
    'status': 'pending',
    'created_at': created_at,
    'updated_at': created_at
}

print(f"🔵 Creando reserva de prueba para {user_email}...")
print(f"   Origen: {booking_data['pickup_address']}")
print(f"   Destino: {booking_data['destination_address']}")
print(f"   Hora recogida: {booking_data['pickup_time']}")
print(f"   Vehículo: {booking_data['vehicle_name']}")
print(f"   Pasajeros: {booking_data['passengers']}")
print(f"   Tarifa: ${booking_data['price']:,.0f} COP")
print(f"   Distancia: {booking_data['distance_text']}")
print(f"   Duración: {booking_data['duration_text']}")
print(f"   Estado: {booking_data['status']}")

# Insertar en la base de datos
cursor.execute("""
    INSERT INTO vlx_bookings 
    (user_id, pickup_address, pickup_lat, pickup_lng, destination_address, destination_lat, 
     destination_lng, pickup_time, vehicle_name, passengers, price, distance_miles, 
     distance_text, duration_text, service_type, is_scheduled, status, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
""", (
    booking_data['user_id'],
    booking_data['pickup_address'],
    booking_data['pickup_lat'],
    booking_data['pickup_lng'],
    booking_data['destination_address'],
    booking_data['destination_lat'],
    booking_data['destination_lng'],
    booking_data['pickup_time'],
    booking_data['vehicle_name'],
    booking_data['passengers'],
    booking_data['price'],
    booking_data['distance_miles'],
    booking_data['distance_text'],
    booking_data['duration_text'],
    booking_data['service_type'],
    booking_data['is_scheduled'],
    booking_data['status'],
    booking_data['created_at'],
    booking_data['updated_at']
))

conn.commit()
booking_id = cursor.lastrowid

print(f"\n✅ Reserva creada exitosamente!")
print(f"   ID de reserva: {booking_id}")

# Verificar que se guardó
cursor.execute("SELECT * FROM vlx_bookings WHERE id = ?", (booking_id,))
booking = cursor.fetchone()

if booking:
    print(f"\n📋 Verificación en base de datos:")
    print(f"   ID: {booking[0]}")
    print(f"   User ID: {booking[1]}")
    print(f"   Origen: {booking[2]}")
    print(f"   Destino: {booking[5]}")
    print(f"   Hora: {booking[8]}")
    print(f"   Vehículo: {booking[9]}")
    print(f"   Pasajeros: {booking[10]}")
    print(f"   Tarifa: ${booking[11]:,.0f}")
    print(f"   Estado: {booking[17]}")
    print(f"\n🔑 Credenciales para login:")
    print(f"   Email: {user_email}")
    print(f"   Contraseña: password123")
    print(f"\n📱 Ahora puedes abrir la app, hacer login y ver esta reserva en 'Mis Reservas'")
else:
    print("\n❌ Error: No se pudo verificar la reserva")

conn.close()
