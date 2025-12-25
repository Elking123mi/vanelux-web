"""
Registrar usuario elkinjeremias123@gmail.com via Railway backend
que LUEGO lo guardará en Supabase
"""
import requests

RAILWAY_URL = "https://web-production-700fe.up.railway.app"

nuevo_usuario = {
    "username": "elkinjeremias123",
    "email": "elkinjeremias123@gmail.com",
    "password": "azlanzapata143@",
    "full_name": "Elkin Chila",
    "phone": "+1234567890",
    "roles": ["passenger"],
    "allowed_apps": ["vanelux", "conexaship"]
}

print("=" * 80)
print("🚀 REGISTRANDO USUARIO VIA RAILWAY → SUPABASE")
print("=" * 80)
print(f"📧 Email: {nuevo_usuario['email']}")
print(f"👤 Nombre: {nuevo_usuario['full_name']}")
print()

try:
    # Registrar usuario via Railway (que lo guardará en Supabase)
    print("📝 Enviando registro a Railway backend...")
    url = f"{RAILWAY_URL}/api/v1/auth/register"
    headers = {"Content-Type": "application/json"}
    
    response = requests.post(url, json=nuevo_usuario, headers=headers, timeout=30)
    
    print(f"Status: {response.status_code}")
    
    if response.status_code in [200, 201]:
        data = response.json()
        print("✅ USUARIO CREADO EXITOSAMENTE EN SUPABASE!")
        print(f"    User ID: {data.get('user_id')}")
        print(f"    Email: {data.get('email')}")
        print(f"    Nombre: {data.get('name') or data.get('full_name')}")
        print(f"\n✅ Ahora ConexaShip DEBERÍA ver este usuario!")
    elif response.status_code == 400:
        error_data = response.json()
        if "already" in str(error_data).lower() or "exist" in str(error_data).lower():
            print("⚠️  EL USUARIO YA EXISTE EN SUPABASE!")
            print("✅ ConexaShip debería poder verlo ahora")
        else:
            print(f"❌ Error 400: {error_data}")
    elif response.status_code == 422:
        print(f"❌ Error de validación: {response.json()}")
    else:
        print(f"❌ Error {response.status_code}: {response.text}")

except Exception as e:
    print(f"❌ ERROR: {e}")

print()
print("=" * 80)
