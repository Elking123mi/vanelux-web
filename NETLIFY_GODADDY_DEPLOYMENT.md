# 🌐 VaneLux Web - Despliegue en Netlify + GoDaddy

**Fecha:** 2 de Diciembre, 2025  
**Objetivo:** Desplegar Flutter Web en Netlify y conectar dominio de GoDaddy

---

## 📋 **Resumen de Arquitectura**

```
┌─────────────────────────────────────────────────┐
│          Usuarios (Navegadores Web)             │
│     Chrome, Firefox, Safari, Edge, etc.         │
└────────────────┬────────────────────────────────┘
                 │ HTTPS
                 ▼
┌─────────────────────────────────────────────────┐
│         Dominio GoDaddy (tudominio.com)         │
│              DNS Configuration                   │
│    A Record / CNAME → Netlify Servers           │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│      Netlify (Frontend Hosting - CDN)           │
│        VaneLux Flutter Web App                  │
│    - HTML, CSS, JavaScript compilados           │
│    - SSL/HTTPS automático (Let's Encrypt)       │
│    - CDN Global para velocidad                  │
└────────────────┬────────────────────────────────┘
                 │ API Calls (HTTPS)
                 ▼
┌─────────────────────────────────────────────────┐
│    Backend FastAPI (Railway)                    │
│    https://web-production-700fe.up.railway.app  │
│    - Autenticación (JWT)                        │
│    - API de Reservas                            │
│    - Gestión de Usuarios                        │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│    Base de Datos PostgreSQL (Supabase)         │
│    - users, vlx_bookings, refresh_tokens        │
└─────────────────────────────────────────────────┘
```

---

## 🎯 **Paso 1: Compilar Flutter Web**

### **1.1 Limpiar builds anteriores**
```bash
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
flutter clean
```

### **1.2 Compilar para producción**
```bash
flutter build web --release
```

**Esto generará:**
- Carpeta: `build/web/`
- Archivos: `index.html`, `main.dart.js`, `flutter.js`, etc.
- Todo optimizado y minificado para producción

### **1.3 Verificar compilación**
```bash
# Ver archivos generados
ls build/web/
```

**Deberías ver:**
- `index.html` ← Página principal
- `flutter.js` ← Motor de Flutter
- `assets/` ← Recursos (imágenes, fuentes, etc.)
- `canvaskit/` ← Renderer de Flutter

---

## 🐙 **Paso 2: Subir a GitHub**

### **2.1 Crear repositorio en GitHub**
1. Ve a: https://github.com
2. Click en **"New repository"**
3. Nombre: `vanelux-web`
4. Descripción: `VaneLux - Luxury Transport Web App (Flutter)`
5. Tipo: **Public** (para Netlify gratuito)
6. ✅ Inicializar con README: **NO** (ya tenemos código)
7. Click en **"Create repository"**

### **2.2 Preparar repositorio local**

**Opción A: Solo subir build/web/ (Más simple)**
```bash
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app\build\web"
git init
git add .
git commit -m "VaneLux Web - Initial deployment"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/vanelux-web.git
git push -u origin main
```

**Opción B: Subir proyecto completo (Recomendado)**
```bash
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"

# Crear .gitignore si no existe
echo "build/" > .gitignore
echo ".dart_tool/" >> .gitignore
echo ".flutter-plugins" >> .gitignore
echo ".flutter-plugins-dependencies" >> .gitignore
echo "pubspec.lock" >> .gitignore

git init
git add .
git commit -m "VaneLux Web - Initial deployment"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/vanelux-web.git
git push -u origin main
```

> **💡 TIP:** Usa la **Opción B** si quieres que Netlify compile automáticamente. Usa **Opción A** si prefieres subir solo los archivos compilados.

---

## 🚀 **Paso 3: Desplegar en Netlify**

### **3.1 Crear cuenta en Netlify**
1. Ve a: https://www.netlify.com
2. Click en **"Sign up"**
3. Elige: **"Sign up with GitHub"** (más fácil)
4. Autoriza Netlify para acceder a tus repositorios

### **3.2 Importar proyecto desde GitHub**

#### **Si usaste Opción A (solo build/web/):**
1. Click en **"Add new site"** → **"Import an existing project"**
2. Selecciona **"Deploy with GitHub"**
3. Busca y selecciona: `vanelux-web`
4. **Build settings:**
   - **Base directory:** (dejar vacío)
   - **Build command:** (dejar vacío)
   - **Publish directory:** `.` (punto)
5. Click en **"Deploy site"**

#### **Si usaste Opción B (proyecto completo):**
1. Click en **"Add new site"** → **"Import an existing project"**
2. Selecciona **"Deploy with GitHub"**
3. Busca y selecciona: `vanelux-web`
4. **Build settings:**
   - **Base directory:** (dejar vacío)
   - **Build command:** `flutter build web --release`
   - **Publish directory:** `build/web`
5. **Antes de Deploy, agregar variable de entorno:**
   - Click en **"Show advanced"**
   - Click en **"New variable"**
   - Key: `FLUTTER_VERSION`
   - Value: `3.24.5` (o tu versión actual)
6. Click en **"Deploy site"**

### **3.3 Esperar despliegue**
- Netlify construirá y desplegará tu sitio
- Tiempo estimado: 2-5 minutos
- Verás logs en tiempo real

### **3.4 Obtener URL temporal**
Una vez completado, Netlify te dará una URL como:
```
https://random-name-12345.netlify.app
```

**Prueba tu sitio:**
1. Abre la URL en tu navegador
2. Deberías ver tu app VaneLux
3. Prueba hacer login con: `elkinjeremias123@gmail.com`

---

## 🔧 **Paso 4: Configurar CORS en Backend (Si es necesario)**

Si al probar la web ves errores de CORS, necesitas actualizar el backend:

### **4.1 Actualizar CORS en Railway**

Edita el archivo `main.py` en tu backend y asegúrate de tener:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://localhost:3000",
        "https://*.netlify.app",  # ← Permitir todos los dominios de Netlify
        "https://tudominio.com",  # ← Tu dominio personalizado
        "https://www.tudominio.com",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### **4.2 Hacer push a GitHub**
```bash
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\backend"
git add main.py
git commit -m "Update CORS for Netlify"
git push
```

Railway detectará el cambio y redesplegará automáticamente.

---

## 🌐 **Paso 5: Conectar Dominio de GoDaddy**

### **5.1 Agregar dominio personalizado en Netlify**

1. En tu sitio de Netlify, ve a: **"Site settings"** → **"Domain management"**
2. Click en **"Add custom domain"**
3. Ingresa tu dominio: `tudominio.com`
4. Netlify te mostrará instrucciones de DNS

### **5.2 Configurar DNS en GoDaddy**

#### **Opción A: Usar Nameservers de Netlify (Recomendado)**

**Ventajas:**
- ✅ SSL/HTTPS automático
- ✅ CDN global incluido
- ✅ Configuración más simple

**Pasos:**
1. En Netlify, ve a: **"Domain settings"** → **"Netlify DNS"**
2. Click en **"Set up Netlify DNS"**
3. Netlify te dará 4 nameservers como:
   ```
   dns1.p05.nsone.net
   dns2.p05.nsone.net
   dns3.p05.nsone.net
   dns4.p05.nsone.net
   ```

4. Ve a GoDaddy: https://dcc.godaddy.com/manage/
5. Selecciona tu dominio
6. Ve a: **"DNS"** → **"Nameservers"**
7. Click en **"Change"**
8. Selecciona: **"I'll use my own nameservers"**
9. Ingresa los 4 nameservers de Netlify
10. Click en **"Save"**

**⏰ Tiempo de propagación:** 24-48 horas (pero usualmente 1-2 horas)

---

#### **Opción B: Usar registros DNS de GoDaddy**

**Ventajas:**
- ✅ Mantienes control en GoDaddy
- ✅ Puedes tener subdominios adicionales

**Pasos:**
1. Ve a GoDaddy: https://dcc.godaddy.com/manage/
2. Selecciona tu dominio
3. Ve a: **"DNS"** → **"Manage DNS"**
4. Agrega los siguientes registros:

**Registro A (para raíz del dominio):**
```
Type: A
Name: @
Value: 75.2.60.5
TTL: 600 seconds
```

**Registro CNAME (para www):**
```
Type: CNAME
Name: www
Value: random-name-12345.netlify.app
TTL: 600 seconds
```

**Registro CNAME para Netlify (verificación):**
```
Type: CNAME
Name: _netlify
Value: [valor que Netlify te proporciona]
TTL: 600 seconds
```

5. Guarda los cambios

**⏰ Tiempo de propagación:** 10 minutos - 2 horas

---

## 🔒 **Paso 6: Configurar SSL/HTTPS**

### **6.1 SSL automático en Netlify**

Netlify configura SSL automáticamente con Let's Encrypt:

1. Ve a: **"Site settings"** → **"Domain management"** → **"HTTPS"**
2. Espera a que aparezca: **"Your site has HTTPS enabled"** ✅
3. Activa: **"Force HTTPS"** (redirige HTTP → HTTPS)

**Tiempo:** 5-10 minutos después de configurar DNS

---

## ✅ **Paso 7: Verificación Final**

### **7.1 Checklist de verificación**

- [ ] Sitio accesible desde `https://tudominio.com` ✅
- [ ] Sitio accesible desde `https://www.tudominio.com` ✅
- [ ] HTTP redirige a HTTPS automáticamente ✅
- [ ] Certificado SSL válido (candado verde 🔒) ✅
- [ ] Login funciona correctamente ✅
- [ ] Crear reserva funciona ✅
- [ ] Reservas se guardan en Supabase ✅
- [ ] Sincronización con apps móviles funciona ✅

### **7.2 Probar desde navegador**

1. Abre: `https://tudominio.com`
2. Haz login con: `elkinjeremias123@gmail.com` / `azlanzapata143@`
3. Crea una reserva de prueba
4. Verifica en Supabase que se guardó

### **7.3 Probar sincronización**

1. Crea reserva desde **Web** (tudominio.com)
2. Abre app **Windows** o **Android**
3. Haz login con el mismo usuario
4. Deberías ver la reserva creada desde web 🎉

---

## 🎨 **Paso 8: Personalizar Dominio (Opcional)**

### **8.1 Cambiar nombre del sitio en Netlify**
1. Ve a: **"Site settings"** → **"General"** → **"Site details"**
2. Click en **"Change site name"**
3. Nuevo nombre: `vanelux` (quedará: `vanelux.netlify.app`)

### **8.2 Configurar subdominios**

**Para app de pasajeros:**
```
app.tudominio.com → vanelux.netlify.app
```

**Para app de conductores:**
```
driver.tudominio.com → vanelux-driver.netlify.app
```

**Agregar en GoDaddy:**
```
Type: CNAME
Name: app
Value: vanelux.netlify.app
TTL: 600
```

---

## 🔧 **Troubleshooting (Solución de Problemas)**

### **Error: "404 Not Found" al recargar página**

**Problema:** Flutter Web usa rutas client-side, pero Netlify busca archivos reales.

**Solución:** Crear archivo `_redirects` en `web/`:

```bash
# Archivo: web/_redirects
/*    /index.html   200
```

Recompilar:
```bash
flutter build web --release
```

Y hacer push a GitHub.

---

### **Error: "CORS policy blocked"**

**Problema:** Backend no permite peticiones desde tu dominio.

**Solución:**
1. Edita `backend/main.py`
2. Agrega tu dominio en `allow_origins`:
   ```python
   allow_origins=[
       "https://tudominio.com",
       "https://www.tudominio.com",
   ]
   ```
3. Hacer push a GitHub
4. Railway redesplegará automáticamente

---

### **Error: "DNS_PROBE_FINISHED_NXDOMAIN"**

**Problema:** DNS aún no se ha propagado.

**Soluciones:**
- Espera 1-2 horas
- Limpia caché DNS: `ipconfig /flushdns` (Windows)
- Verifica DNS: https://dnschecker.org

---

### **Error: "NET::ERR_CERT_AUTHORITY_INVALID"**

**Problema:** SSL aún no está configurado.

**Solución:**
- Espera 10-15 minutos
- Verifica en Netlify: **"Domain management"** → **"HTTPS"**
- Si sigue sin funcionar, intenta: **"Renew certificate"**

---

## 📊 **Costos y Límites**

### **Netlify Free Plan:**
- ✅ **100 GB** de ancho de banda/mes
- ✅ **300 build minutes** por mes
- ✅ **Dominios personalizados ilimitados**
- ✅ **SSL/HTTPS automático**
- ✅ **CDN global**
- ✅ **Deploy automático desde GitHub**

### **GoDaddy:**
- 💰 Costo del dominio: ~$10-15 USD/año
- ✅ DNS management incluido
- ✅ Sin costo adicional por registros DNS

### **Railway Backend:**
- ✅ **$5/mes incluidos** (plan Developer)
- ⚠️ **$0.20/hora** después de gastar los $5

### **Supabase:**
- ✅ **Gratis hasta 500MB** de base de datos
- ✅ **50,000 usuarios activos/mes**

**Total estimado:** **$0-5 USD/mes** (si no excedes los límites gratuitos)

---

## 📚 **Recursos Adicionales**

### **Documentación oficial:**
- Netlify: https://docs.netlify.com
- GoDaddy DNS: https://www.godaddy.com/help/manage-dns-680
- Flutter Web: https://docs.flutter.dev/deployment/web

### **Herramientas útiles:**
- DNS Checker: https://dnschecker.org
- SSL Checker: https://www.sslshopper.com/ssl-checker.html
- Page Speed: https://pagespeed.web.dev

### **Tutoriales:**
- Deploy Flutter Web: https://www.youtube.com/results?search_query=flutter+web+netlify
- GoDaddy DNS setup: https://www.youtube.com/results?search_query=godaddy+netlify+dns

---

## 🎯 **Resumen de Comandos Rápidos**

```bash
# 1. Compilar Flutter Web
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
flutter clean
flutter build web --release

# 2. Subir a GitHub (Opción A - solo build)
cd build\web
git init
git add .
git commit -m "VaneLux Web - Initial deployment"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/vanelux-web.git
git push -u origin main

# 3. En Netlify (interfaz web):
# - Importar desde GitHub
# - Deploy site
# - Configurar dominio personalizado

# 4. En GoDaddy (interfaz web):
# - Agregar nameservers de Netlify
# - O agregar registros A/CNAME

# 5. Esperar propagación DNS (1-2 horas)

# 6. ¡Listo! 🎉
```

---

## 🎉 **¡Felicidades!**

Una vez completados todos los pasos, tu app **VaneLux** estará:

✅ Desplegada en **Netlify** con CDN global  
✅ Accesible desde tu **dominio personalizado**  
✅ Con **SSL/HTTPS** automático y seguro  
✅ Conectada al **backend en Railway**  
✅ Sincronizada con **Supabase** (PostgreSQL)  
✅ Disponible 24/7 para usuarios en todo el mundo 🌍  

---

**Última actualización:** 2 de Diciembre, 2025  
**Autor:** Elkin Chila  
**Stack:** Flutter Web + Netlify + Railway + Supabase + GoDaddy
