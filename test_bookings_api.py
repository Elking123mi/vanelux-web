import requests
import json

print("=" * 80)
print("TEST 1: Consultar reservas SIN autenticación")
print("=" * 80)
try:
    resp1 = requests.get('http://192.168.1.43:3000/api/vlx/bookings')
    print(f"Status: {resp1.status_code}")
    print(f"Response: {resp1.text[:500]}")
except Exception as e:
    print(f"Error: {e}")

print("\n" + "=" * 80)
print("TEST 2: Login con credenciales")
print("=" * 80)
try:
    login_resp = requests.post(
        'http://192.168.1.43:3000/api/auth/login',
        json={
            'username': 'chilaelkin4@gmail.com',
            'password': 'chila123',
            'app': 'vanelux'
        }
    )
    print(f"Login Status: {login_resp.status_code}")
    login_data = login_resp.json() if login_resp.status_code == 200 else login_resp.json()
    print(f"Login Response: {json.dumps(login_data, indent=2)}")
    
    if 'access_token' in login_data:
        token = login_data['access_token']
        print(f"\n✅ Token obtenido: {token[:50]}...")
        
        print("\n" + "=" * 80)
        print("TEST 3: Consultar reservas CON autenticación")
        print("=" * 80)
        resp3 = requests.get(
            'http://192.168.1.43:3000/api/vlx/bookings',
            headers={'Authorization': f'Bearer {token}'}
        )
        print(f"Status: {resp3.status_code}")
        print(f"Response: {json.dumps(resp3.json(), indent=2)}")
    else:
        print("❌ No se obtuvo token de acceso")
except Exception as e:
    print(f"Error: {e}")
