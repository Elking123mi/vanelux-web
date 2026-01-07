# 🔐 Configuración de Variables de Entorno en Netlify

## ⚠️ PROBLEMA RESUELTO:

El build fallaba porque Netlify detectaba la Google Maps API Key como un "secreto" en el código.

**Error anterior:**
```
❌ "AIzaSy***" detected as a likely secret
❌ Secrets scanning found secrets in build
```

---

## ✅ SOLUCIÓN IMPLEMENTADA:

Ahora la API Key se pasa como **variable de entorno** en vez de estar hardcodeada en el código.

---

## 📋 PASOS PARA CONFIGURAR EN NETLIFY:

### 1️⃣ **Ve a tu sitio en Netlify Dashboard**
- Abre: https://app.netlify.com
- Selecciona tu sitio "Vanelux"

### 2️⃣ **Configurar Variables de Entorno**
1. Haz clic en **"Site settings"**
2. En el menú lateral, ve a **"Environment variables"**
3. Haz clic en **"Add a variable"**

### 3️⃣ **Agregar Google Maps API Key**

**Variable 1:**
- **Key:** `GOOGLE_MAPS_API_KEY`
- **Value:** `[TU_GOOGLE_MAPS_API_KEY]` (usa tu propia API key de Google Cloud Console)
- **Scopes:** Selecciona "All scopes"

### 4️⃣ **Guardar y Redesplegar**

1. Haz clic en **"Save"**
2. Ve a **"Deploys"** en el menú superior
3. Haz clic en **"Trigger deploy"** → **"Deploy site"**

---

## 🔄 CÓMO FUNCIONA AHORA:

### **En el código (app_config.dart):**
```dart
static const String googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: 'CHANGE_ME',
);
```

### **En netlify.toml:**
```bash
flutter build web --release --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY
```

### **En Netlify Dashboard:**
- La variable `GOOGLE_MAPS_API_KEY` se configura de forma segura
- Netlify la inyecta durante el build
- ✅ No se expone en el código fuente

---

## 🎯 VERIFICAR QUE FUNCIONA:

Después de configurar y redesplegar, deberías ver:

✅ **Build exitoso** sin errores de "secrets detected"
✅ **Google Maps funcionando** en tu web
✅ **API Key segura** (no visible en el código público)

---

## 📝 VARIABLES ADICIONALES (Opcional)

Si más adelante necesitas otras API keys, agrégalas de la misma forma:

**OpenAI (para el asistente):**
- Key: `OPENAI_API_KEY`
- Value: tu_openai_key_aquí

**Stripe (para pagos):**
- Key: `STRIPE_PUBLIC_KEY`
- Value: tu_stripe_public_key
- Key: `STRIPE_SECRET_KEY`
- Value: tu_stripe_secret_key

---

## 🚨 IMPORTANTE:

- ❌ **NUNCA** subas API keys directamente en el código
- ✅ **SIEMPRE** usa variables de entorno para información sensible
- ✅ **Agrega `.env` al `.gitignore`** para que no se suba accidentalmente

---

## 🔗 DOCUMENTACIÓN OFICIAL:

- **Netlify Environment Variables:** https://docs.netlify.com/environment-variables/overview/
- **Flutter dart-define:** https://docs.flutter.dev/deployment/flavors

---

**Última actualización:** 24 de diciembre, 2025
