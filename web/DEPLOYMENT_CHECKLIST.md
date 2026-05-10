# Vanelux Web - Checklist de Verificación Post-Deploy

## 🔍 Verificación Rápida

### 1. ✅ Archivos Creados
- [ ] `/web/robots.txt` existe
- [ ] `/web/sitemap.xml` ampliado (12+ URLs)
- [ ] `/web/_headers` con security headers
- [ ] `/web/netlify.toml` configurado
- [ ] `/web/browserconfig.xml` para Windows tiles
- [ ] `/web/humans.txt` con info del equipo
- [ ] `/web/SECURITY.md` con política de seguridad
- [ ] `/web/jfk-limo.html` landing page
- [ ] `/web/airport-transfer.html` landing page
- [ ] `/web/corporate-transportation.html` landing page

### 2. ✅ Index.html Modificado
- [ ] `<html lang="en">` agregado
- [ ] Splash screen con logo y spinner
- [ ] Botón flotante de WhatsApp
- [ ] Preload de assets críticos
- [ ] Schema LocalBusiness con reviews
- [ ] Script para ocultar splash cuando carga

### 3. ✅ Manifest.json Mejorado
- [ ] Categories añadidas
- [ ] Screenshots configurados
- [ ] Shortcuts (Book, Contact)
- [ ] Share target configurado
- [ ] Lang y scope definidos

---

## 🌐 Pruebas Online (Después de Deploy)

### SEO
```
1. Sitemap accesible:
   https://www.vane-lux.com/sitemap.xml
   
2. Robots.txt accesible:
   https://www.vane-lux.com/robots.txt
   
3. Landing pages funcionando:
   https://www.vane-lux.com/jfk-limo.html
   https://www.vane-lux.com/airport-transfer.html
   https://www.vane-lux.com/corporate-transportation.html
```

### Herramientas de Verificación

#### Performance
- **PageSpeed Insights**: https://pagespeed.web.dev/
  - Target: Performance 80+, SEO 95+
  
- **GTmetrix**: https://gtmetrix.com/
  - Target: Grade A, Load Time < 3s

#### SEO
- **Google Rich Results Test**: https://search.google.com/test/rich-results
  - Debe detectar: TaxiService, LocalBusiness, FAQPage
  
- **Schema.org Validator**: https://validator.schema.org/
  - Pegar el HTML de index.html
  
- **Google Search Console**: 
  - Enviar sitemap manualmente
  - Verificar cobertura de índice

#### Security
- **Security Headers**: https://securityheaders.com/
  - Target: A o A+
  
- **SSL Labs**: https://www.ssllabs.com/ssltest/
  - Target: A o A+
  
- **Observatory Mozilla**: https://observatory.mozilla.org/
  - Target: 90+

#### PWA
- **Chrome DevTools**:
  1. Abrir https://www.vane-lux.com
  2. DevTools > Application > Manifest
  3. Verificar: ✅ No errors, ✅ Installable
  4. Lighthouse > Progressive Web App: 90+

#### Mobile-Friendly
- **Google Mobile-Friendly Test**: https://search.google.com/test/mobile-friendly
  - Debe pasar sin errores

---

## 🧪 Pruebas Locales (Antes de Deploy)

### Flutter Build Test
```bash
cd luxury_taxi_app

# Build for web
flutter build web --release --web-renderer auto

# Verificar output
ls -la build/web/

# Archivos esperados:
# - index.html (modificado)
# - manifest.json (mejorado)
# - robots.txt (nuevo)
# - sitemap.xml (ampliado)
# - _headers (nuevo)
# - netlify.toml (nuevo)
# - *.html landing pages (nuevos)
```

### Servidor Local de Prueba
```bash
# Opción 1: Flutter Web Server
flutter run -d web-server --web-port=8888

# Opción 2: Python HTTP Server
cd build/web
python -m http.server 8000

# Opción 3: Node.js http-server
npx http-server build/web -p 8000

# Visitar: http://localhost:8000
```

### Verificaciones en Local

#### 1. Splash Screen
- [ ] Logo de Vanelux visible
- [ ] Spinner animado (dorado)
- [ ] Texto "VANELUX" aparece
- [ ] Splash desaparece después de ~1s

#### 2. WhatsApp Button
- [ ] Botón verde flotante visible (esquina inferior derecha)
- [ ] Icono de WhatsApp renderizado
- [ ] Hover effect funciona (scale 1.1)
- [ ] Click abre: `https://wa.me/19175995522?text=...`

#### 3. Meta Tags (View Source)
```html
<!-- Buscar en el HTML: -->
<html lang="en">  <!-- ✅ -->
<link rel="preload" as="image" href="icons/Icon-192.png">  <!-- ✅ -->
<script type="application/ld+json">  <!-- 3 bloques ✅ -->
```

#### 4. Landing Pages
Abrir en navegador:
- [ ] `jfk-limo.html` renderiza correctamente
- [ ] `airport-transfer.html` renderiza correctamente
- [ ] `corporate-transportation.html` renderiza correctamente
- [ ] Botones CTA funcionan (teléfono, WhatsApp, booking)

---

## 📊 Métricas a Monitorear

### Google Analytics (GA4)
```javascript
// Eventos importantes:
- page_view (todas las páginas)
- click (botones CTA)
- ads_conversion_Compra_1 (conversión)
- booking_start
- booking_complete
```

### Core Web Vitals
- **LCP** (Largest Contentful Paint): < 2.5s
- **FID** (First Input Delay): < 100ms
- **CLS** (Cumulative Layout Shift): < 0.1

### Conversión
- **Bounce rate**: Target < 50%
- **Session duration**: Target > 2 min
- **Click en WhatsApp**: Medir CTR
- **Booking funnel**: Start → Complete

---

## ⚠️ Troubleshooting

### Problema: Splash screen no desaparece
**Solución**: Verificar en DevTools Console errores de JavaScript. El script `window.addEventListener('load')` debe ejecutarse.

### Problema: WhatsApp button no visible
**Solución**: 
1. Verificar que el HTML del botón esté en `<body>`
2. Revisar CSS para `#whatsapp-float`
3. Verificar z-index no esté sobrescrito

### Problema: Headers de seguridad no aplican
**Solución**: 
- En Netlify: `_headers` debe estar en `build/web/` (copiarlo manualmente si no)
- Verificar sintaxis en https://docs.netlify.com/routing/headers/

### Problema: Sitemap no indexado en Google
**Solución**:
1. Google Search Console > Sitemaps
2. Enviar: `https://www.vane-lux.com/sitemap.xml`
3. Esperar 24-48h para indexación

### Problema: Landing pages no cargan (404)
**Solución**:
- Verificar que `*.html` estén en `build/web/`
- Si usas hash routing (#/), cambiar a path routing en Flutter
- Revisar `_redirects` o `netlify.toml` redirects

### Problema: CSP bloquea scripts
**Solución**: 
- DevTools Console mostrará URLs bloqueadas
- Agregar dominios a `Content-Security-Policy` en `_headers`
- Ejemplo: `script-src 'self' https://nuevo-dominio.com`

---

## 🎯 Checklist Final Pre-Launch

### Desarrollo
- [ ] `flutter analyze` sin errores
- [ ] `flutter test` pasa todos los tests
- [ ] Build local exitoso (`flutter build web --release`)
- [ ] Verificación visual en Chrome, Safari, Firefox
- [ ] Verificación móvil (iOS Safari, Chrome Android)

### SEO
- [ ] Meta tags correctos en todas las páginas
- [ ] Sitemap.xml válido (https://www.xml-sitemaps.com/validate-xml-sitemap.html)
- [ ] Robots.txt válido
- [ ] Structured data sin errores (Rich Results Test)
- [ ] Canonical URLs configurados

### Seguridad
- [ ] HTTPS forzado
- [ ] Security headers configurados
- [ ] CSP sin errores en Console
- [ ] Credenciales sensibles en variables de entorno (no en código)

### Performance
- [ ] Imágenes optimizadas (WebP preferido)
- [ ] Assets críticos precargados
- [ ] Cache headers configurados
- [ ] Lazy loading implementado
- [ ] Service worker registrado

### UX
- [ ] Splash screen funciona
- [ ] WhatsApp button funciona
- [ ] CTA buttons prominentes
- [ ] Formularios validados
- [ ] Error handling implementado
- [ ] Loading states visibles

### Analytics
- [ ] Google Analytics configurado
- [ ] Google Tag Manager (opcional)
- [ ] Conversión tracking activo
- [ ] Error tracking (Sentry, opcional)

---

## ✅ Sign-Off

**Desarrollador**: _______________  
**Fecha**: _______________  
**QA Pass**: [ ] Sí [ ] No  
**Deploy Autorizado**: [ ] Sí [ ] No  

**Notas adicionales**:
_________________________________
_________________________________
_________________________________

---

**🚀 ¡Listo para deploy cuando todos los checks estén ✅!**
