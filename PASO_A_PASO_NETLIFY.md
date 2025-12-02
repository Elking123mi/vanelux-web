# 🚀 Guía Rápida: VaneLux Web → GitHub → Netlify → GoDaddy

**Status:** ✅ Git inicializado | ✅ Primer commit listo | ⏳ Esperando GitHub

---

## 📦 PASO 1: Crear Repositorio en GitHub (TÚ LO HACES)

### **1.1 Ve a GitHub:**
```
https://github.com/new
```

### **1.2 Configura el repositorio:**
```
Repository name: vanelux-web
Description: VaneLux - Luxury Transport Web App (Flutter)
Visibility: ✅ Public (necesario para Netlify gratuito)
❌ NO marcar "Add a README file"
❌ NO marcar "Add .gitignore"
❌ NO marcar "Choose a license"
```

### **1.3 Click en "Create repository"**

### **1.4 COPIA LA URL QUE APARECE:**
Busca donde dice: **"...or push an existing repository from the command line"**

La URL será algo como:
```
https://github.com/TU-USUARIO/vanelux-web.git
```

**🎯 DIME ESA URL CUANDO LA TENGAS Y YO CONTINÚO**

---

## 📤 PASO 2: Subir Código a GitHub (YO LO HAGO)

Una vez me des la URL, yo ejecutaré:
```bash
git remote add origin https://github.com/TU-USUARIO/vanelux-web.git
git branch -M main
git push -u origin main
```

---

## 🌐 PASO 3: Conectar Netlify (TÚ LO HACES, YO TE GUÍO)

### **3.1 Ve a Netlify:**
```
https://app.netlify.com/signup
```

### **3.2 Sign up con GitHub:**
- Click en **"Sign up with GitHub"**
- Autoriza Netlify para acceder a tus repositorios

### **3.3 Importar proyecto:**
1. Click en **"Add new site"** → **"Import an existing project"**
2. Click en **"Deploy with GitHub"**
3. Busca y selecciona: **vanelux-web**
4. **Build settings:**
   ```
   Base directory: (dejar vacío)
   Build command: flutter build web --release
   Publish directory: build/web
   ```
5. **Variables de entorno** (Click en "Add environment variables"):
   ```
   FLUTTER_VERSION = stable
   ```
6. Click en **"Deploy site"**

### **3.4 Esperar 3-5 minutos:**
Netlify compilará y desplegará tu app. Verás algo como:
```
✅ Site is live!
https://random-name-12345.netlify.app
```

**🎯 PRUEBA ESA URL EN TU NAVEGADOR**
- Deberías ver tu app VaneLux
- Intenta hacer login
- Crea una reserva de prueba

---

## 🌐 PASO 4: Conectar Dominio GoDaddy (TÚ LO HACES)

### **4.1 En Netlify:**
1. Ve a: **"Domain settings"** → **"Add custom domain"**
2. Ingresa tu dominio: `tudominio.com`
3. Click en **"Verify"**
4. Netlify te dirá que necesitas configurar DNS

### **4.2 En GoDaddy:**

**Opción A: Nameservers de Netlify (Recomendado)** ⭐
1. Netlify te dará 4 nameservers como:
   ```
   dns1.p05.nsone.net
   dns2.p05.nsone.net
   dns3.p05.nsone.net
   dns4.p05.nsone.net
   ```
2. Ve a GoDaddy: https://dcc.godaddy.com/manage/
3. Selecciona tu dominio
4. Click en **"DNS"** → **"Nameservers"** → **"Change"**
5. Selecciona: **"I'll use my own nameservers"**
6. Pega los 4 nameservers de Netlify
7. Click en **"Save"**

**Opción B: Registros DNS**
1. Ve a GoDaddy: https://dcc.godaddy.com/manage/
2. Selecciona tu dominio
3. Click en **"DNS"** → **"Manage DNS"**
4. Agrega estos registros:

**Registro A:**
```
Type: A
Name: @
Value: 75.2.60.5
TTL: 600
```

**Registro CNAME (www):**
```
Type: CNAME
Name: www
Value: random-name-12345.netlify.app
TTL: 600
```

5. **Guardar cambios**

### **4.3 Esperar propagación DNS:**
- Tiempo estimado: **30 minutos - 2 horas**
- Puedes verificar en: https://dnschecker.org

### **4.4 Activar SSL en Netlify:**
1. Ve a: **"Domain settings"** → **"HTTPS"**
2. Espera a que diga: **"Your site has HTTPS enabled"** ✅
3. Activa: **"Force HTTPS"**

---

## ✅ PASO 5: Verificación Final

### **Prueba tu dominio:**
```
https://tudominio.com
```

**Checklist:**
- [ ] Sitio carga correctamente
- [ ] Login funciona
- [ ] Crear reserva funciona
- [ ] Reserva aparece en Supabase
- [ ] HTTPS activo (candado verde 🔒)
- [ ] Redirección de HTTP → HTTPS funciona

---

## 🔄 WORKFLOW DE ACTUALIZACIONES (IMPORTANTE)

### **Cada vez que hagas cambios en tu app:**

```bash
# 1. Hacer cambios en tu código (ej: cambiar un color, texto, etc.)

# 2. Guardar cambios

# 3. Commit
git add .
git commit -m "Descripción del cambio"

# 4. Push a GitHub
git push

# 5. ¡Netlify detecta el push y despliega automáticamente! 🚀
```

**No necesitas:**
- ❌ Recompilar manualmente
- ❌ Subir archivos por FTP
- ❌ Hacer nada más

**Netlify hace:**
- ✅ Detecta el push automáticamente
- ✅ Compila `flutter build web --release`
- ✅ Despliega los nuevos archivos
- ✅ Tu sitio se actualiza en 2-3 minutos

---

## 📊 Ejemplo de Actualización

```bash
# Supongamos que cambias el título de la app

# 1. Editas: lib/screens/web/web_home_screen.dart
# Cambias: "Welcome" → "Bienvenido"

# 2. Guardas el archivo

# 3. Git commit
cd "C:\Users\elkin\OneDrive\Desktop\vanelux app\luxury_taxi_app"
git add .
git commit -m "Cambiar título a español"
git push

# 4. ¡Listo! En 2-3 minutos verás el cambio en tudominio.com
```

---

## 🆘 Comandos Útiles

```bash
# Ver status de Git
git status

# Ver historial de commits
git log --oneline

# Ver cambios no guardados
git diff

# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Ver remotes configurados
git remote -v

# Actualizar desde GitHub (si trabajas en múltiples PCs)
git pull
```

---

## 🎯 RESUMEN

1. **TÚ:** Creas repositorio en GitHub
2. **TÚ:** Me das la URL del repositorio
3. **YO:** Subo el código
4. **TÚ:** Conectas Netlify con GitHub
5. **TÚ:** Configuras dominio en GoDaddy
6. **AMBOS:** Verificamos que todo funcione
7. **TÚ:** De ahora en adelante: `git push` = actualización automática 🚀

---

## 📞 Siguiente Paso

**🎯 CREA EL REPOSITORIO EN GITHUB Y DAME LA URL**

Cuando lo tengas, me dices:
```
"Listo, la URL es: https://github.com/TU-USUARIO/vanelux-web.git"
```

Y yo subo el código inmediatamente. Luego te guío para conectar Netlify y GoDaddy. 

**¿Listo para crear el repositorio? 🚀**
