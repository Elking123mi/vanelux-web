#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests

# Supabase credentials
SUPABASE_URL = "https://ujkddikmljvccpwrgnvz.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqa2RkaWttbGp2Y2N3d3Jnbnl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxNjk2NzAsImV4cCI6MjA0ODc0NTY3MH0.y2z2b2sLlC5NHG2Z-TIxK10xVFj5JlJ6mw9d3dGjH6Q"

print("=" * 80)
print("🔍 VERIFICANDO USUARIO: elkinjeremias123@gmail.com")
print("=" * 80)

# Headers para Supabase
headers = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json"
}

try:
    # Buscar usuario por email en vlx_passengers
    print("\n📊 Buscando en tabla vlx_passengers...")
    url = f"{SUPABASE_URL}/rest/v1/vlx_passengers?email=eq.elkinjeremias123@gmail.com&select=*"
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        passengers = response.json()
        if passengers:
            print(f"✅ USUARIO ENCONTRADO EN vlx_passengers:")
            for p in passengers:
                print(f"\n  ID: {p.get('id')}")
                print(f"  Email: {p.get('email')}")
                print(f"  Name: {p.get('name')}")
                print(f"  Phone: {p.get('phone')}")
                print(f"  Created: {p.get('created_at')}")
        else:
            print("❌ Usuario NO encontrado en vlx_passengers")
    else:
        print(f"❌ Error al buscar: {response.status_code} - {response.text}")
    
    # Buscar en vlx_bookings
    print("\n📊 Buscando reservas del usuario...")
    url = f"{SUPABASE_URL}/rest/v1/vlx_bookings?passenger_email=eq.elkinjeremias123@gmail.com&select=*"
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        bookings = response.json()
        if bookings:
            print(f"✅ RESERVAS ENCONTRADAS: {len(bookings)}")
            for b in bookings:
                print(f"\n  Booking ID: {b.get('id')}")
                print(f"  From: {b.get('pickup_location')} → To: {b.get('dropoff_location')}")
                print(f"  Status: {b.get('status')}")
                print(f"  Amount: ${b.get('amount')}")
                print(f"  Created: {b.get('created_at')}")
        else:
            print("❌ No se encontraron reservas")
    else:
        print(f"❌ Error al buscar reservas: {response.status_code}")

except Exception as e:
    print(f"\n❌ ERROR: {e}")

print("\n" + "=" * 80)
