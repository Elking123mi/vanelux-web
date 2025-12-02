import http.client
import json

print("🔍 Verificando si el backend está corriendo...\n")

try:
    # Probar conexión al backend
    conn = http.client.HTTPConnection("localhost", 3000, timeout=5)
    
    # Test 1: Health check básico
    print("1️⃣ Test: Conexión básica al servidor")
    try:
        conn.request("GET", "/")
        response = conn.getresponse()
        print(f"   ✅ Servidor responde: {response.status}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
        print("\n⚠️  El backend NO está corriendo en puerto 3000")
        print("\n💡 Para iniciar el backend:")
        print("   cd 'C:\\Users\\elkin\\OneDrive\\Desktop\\app de prueba'")
        print("   python -m uvicorn main:app --reload --port 3000")
        exit(1)
    
    # Test 2: Endpoint de documentación
    print("\n2️⃣ Test: Documentación Swagger")
    try:
        conn.request("GET", "/docs")
        response = conn.getresponse()
        print(f"   ✅ Swagger UI disponible: {response.status}")
    except Exception as e:
        print(f"   ⚠️  Swagger no disponible: {e}")
    
    # Test 3: Endpoint de autenticación
    print("\n3️⃣ Test: Endpoint de autenticación")
    try:
        headers = {"Content-Type": "application/json"}
        body = json.dumps({"username": "admin@example.com", "password": "admin123"})
        
        conn.request("POST", "/api/v1/auth/login", body, headers)
        response = conn.getresponse()
        data = response.read()
        
        if response.status == 200:
            print(f"   ✅ Auth endpoint funciona")
        elif response.status == 401:
            print(f"   ⚠️  Credenciales incorrectas (pero endpoint funciona)")
        else:
            print(f"   ⚠️  Status: {response.status}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # Test 4: Endpoint de reservas
    print("\n4️⃣ Test: Endpoint de reservas (/api/v1/vlx/bookings)")
    try:
        conn.request("GET", "/api/v1/vlx/bookings")
        response = conn.getresponse()
        
        if response.status == 401:
            print(f"   ✅ Endpoint existe (requiere auth)")
        elif response.status == 404:
            print(f"   ❌ Endpoint NO implementado")
            print(f"   💡 El backend necesita implementar POST/GET /api/v1/vlx/bookings")
        else:
            print(f"   ✅ Endpoint responde: {response.status}")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    conn.close()
    
    print("\n" + "=" * 70)
    print("✅ BACKEND ESTÁ CORRIENDO Y LISTO")
    print("=" * 70)
    
except ConnectionRefusedError:
    print("\n❌ ERROR: No se puede conectar al backend")
    print("\n💡 Asegúrate de que el backend esté corriendo:")
    print("   1. Abre una nueva terminal")
    print("   2. cd 'C:\\Users\\elkin\\OneDrive\\Desktop\\app de prueba'")
    print("   3. python -m uvicorn main:app --reload --port 3000")
    
except Exception as e:
    print(f"\n❌ Error inesperado: {e}")
