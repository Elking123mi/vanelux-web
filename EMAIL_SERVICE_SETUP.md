# 📧 Sistema de Correos Automáticos para Vanelux

## 🎯 Objetivo:
Enviar emails automáticos cuando:
- Un cliente hace una reserva
- Un conductor acepta un viaje
- Un viaje se completa
- Se cancela una reserva

---

## 📦 Servicio Recomendado: **SendGrid**

### ¿Por qué SendGrid?
✅ 100 emails/día gratis
✅ No va a spam
✅ Plantillas HTML profesionales
✅ Fácil de usar

---

## 🔧 IMPLEMENTACIÓN

### 1️⃣ Instalar SendGrid en el backend

```bash
cd backend
pip install sendgrid
```

Agregar a `requirements.txt`:
```
sendgrid==6.11.0
```

---

### 2️⃣ Configurar en Railway

**Variables de entorno a agregar:**
- `SENDGRID_API_KEY`: tu-api-key-aquí
- `VANELUX_FROM_EMAIL`: noreply@vanelux.com
- `VANELUX_ADMIN_EMAIL`: admin@vanelux.com

---

### 3️⃣ Código para enviar emails

Crear archivo: `backend/services/email_service.py`

```python
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail, Email, To, Content

class EmailService:
    def __init__(self):
        self.api_key = os.getenv('SENDGRID_API_KEY')
        self.from_email = os.getenv('VANELUX_FROM_EMAIL', 'noreply@vanelux.com')
        self.admin_email = os.getenv('VANELUX_ADMIN_EMAIL', 'admin@vanelux.com')
        self.sg = SendGridAPIClient(self.api_key)
    
    def enviar_confirmacion_reserva(self, cliente_email, cliente_nombre, detalles_reserva):
        """Envía email de confirmación al cliente y notifica al admin"""
        
        # Email para el cliente
        html_cliente = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #0B3254 0%, #1E5A8E 100%); 
                          color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
                .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
                .detail-box {{ background: white; padding: 20px; margin: 20px 0; border-radius: 8px; 
                             border-left: 4px solid #D4AF37; }}
                .footer {{ text-align: center; margin-top: 30px; color: #666; }}
                .btn {{ background: #D4AF37; color: white; padding: 12px 30px; text-decoration: none; 
                       border-radius: 5px; display: inline-block; margin-top: 20px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>✅ Reserva Confirmada</h1>
                    <p>Gracias por elegir Vanelux</p>
                </div>
                <div class="content">
                    <p>Hola <strong>{cliente_nombre}</strong>,</p>
                    <p>Tu reserva ha sido confirmada exitosamente. Aquí están los detalles:</p>
                    
                    <div class="detail-box">
                        <h3>📍 Detalles del Viaje</h3>
                        <p><strong>ID de Reserva:</strong> {detalles_reserva.get('id', 'N/A')}</p>
                        <p><strong>Origen:</strong> {detalles_reserva.get('pickup_address', 'N/A')}</p>
                        <p><strong>Destino:</strong> {detalles_reserva.get('destination_address', 'N/A')}</p>
                        <p><strong>Fecha y Hora:</strong> {detalles_reserva.get('pickup_time', 'N/A')}</p>
                        <p><strong>Vehículo:</strong> {detalles_reserva.get('vehicle_name', 'N/A')}</p>
                        <p><strong>Precio Total:</strong> ${detalles_reserva.get('total_price', 0):.2f}</p>
                    </div>
                    
                    <p>Nos pondremos en contacto contigo pronto para confirmar tu conductor.</p>
                    
                    <div class="footer">
                        <p>¿Necesitas ayuda? Contáctanos:</p>
                        <p>📞 +1 917 599-5522</p>
                        <p>📧 support@vanelux.com</p>
                        <p>🌐 <a href="https://vane-lux.com">vane-lux.com</a></p>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        
        # Email para el admin
        html_admin = f"""
        <h2>🚨 Nueva Reserva - Vanelux</h2>
        <p><strong>Cliente:</strong> {cliente_nombre} ({cliente_email})</p>
        <p><strong>ID Reserva:</strong> {detalles_reserva.get('id')}</p>
        <p><strong>Origen:</strong> {detalles_reserva.get('pickup_address')}</p>
        <p><strong>Destino:</strong> {detalles_reserva.get('destination_address')}</p>
        <p><strong>Fecha:</strong> {detalles_reserva.get('pickup_time')}</p>
        <p><strong>Precio:</strong> ${detalles_reserva.get('total_price', 0):.2f}</p>
        <p><strong>Estado:</strong> {detalles_reserva.get('status', 'pending')}</p>
        <hr>
        <p>Asignar conductor y confirmar el viaje.</p>
        """
        
        try:
            # Enviar al cliente
            message_cliente = Mail(
                from_email=Email(self.from_email, "Vanelux"),
                to_emails=To(cliente_email),
                subject="✅ Tu reserva está confirmada - Vanelux",
                html_content=Content("text/html", html_cliente)
            )
            self.sg.send(message_cliente)
            
            # Enviar al admin
            message_admin = Mail(
                from_email=Email(self.from_email, "Vanelux Sistema"),
                to_emails=To(self.admin_email),
                subject=f"🚨 Nueva Reserva #{detalles_reserva.get('id')} - {cliente_nombre}",
                html_content=Content("text/html", html_admin)
            )
            self.sg.send(message_admin)
            
            return True
        except Exception as e:
            print(f"Error enviando emails: {e}")
            return False
    
    def enviar_asignacion_conductor(self, cliente_email, conductor_nombre, conductor_telefono, detalles_viaje):
        """Notifica al cliente cuando se asigna un conductor"""
        html = f"""
        <h2>🚗 Conductor Asignado - Vanelux</h2>
        <p>Tu viaje ha sido asignado a un conductor profesional:</p>
        <p><strong>Conductor:</strong> {conductor_nombre}</p>
        <p><strong>Teléfono:</strong> {conductor_telefono}</p>
        <p><strong>Hora de recogida:</strong> {detalles_viaje.get('pickup_time')}</p>
        <p>El conductor se pondrá en contacto contigo pronto.</p>
        """
        
        message = Mail(
            from_email=Email(self.from_email, "Vanelux"),
            to_emails=To(cliente_email),
            subject="🚗 Tu conductor ha sido asignado - Vanelux",
            html_content=Content("text/html", html)
        )
        
        try:
            self.sg.send(message)
            return True
        except Exception as e:
            print(f"Error: {e}")
            return False
    
    def enviar_completado_viaje(self, cliente_email, cliente_nombre, detalles_viaje):
        """Envía email cuando el viaje se completa"""
        html = f"""
        <h2>✅ Viaje Completado - Vanelux</h2>
        <p>Hola {cliente_nombre},</p>
        <p>Tu viaje ha sido completado exitosamente.</p>
        <p><strong>Total:</strong> ${detalles_viaje.get('total_price', 0):.2f}</p>
        <p>Gracias por viajar con Vanelux. ¡Esperamos verte pronto!</p>
        <p>⭐⭐⭐⭐⭐</p>
        <p>¿Cómo fue tu experiencia? Déjanos tu opinión.</p>
        """
        
        message = Mail(
            from_email=Email(self.from_email, "Vanelux"),
            to_emails=To(cliente_email),
            subject="✅ Viaje completado - Gracias por elegir Vanelux",
            html_content=Content("text/html", html)
        )
        
        try:
            self.sg.send(message)
            return True
        except Exception as e:
            print(f"Error: {e}")
            return False

# Instancia global
email_service = EmailService()
```

---

### 4️⃣ Usar en los endpoints del backend

En `backend/main.py`, al crear una reserva:

```python
from services.email_service import email_service

@app.post("/api/v1/vlx/bookings")
async def crear_reserva(booking_data: dict):
    # ... crear la reserva en la base de datos ...
    
    # Enviar emails de confirmación
    email_service.enviar_confirmacion_reserva(
        cliente_email=booking_data['customer_email'],
        cliente_nombre=booking_data['customer_name'],
        detalles_reserva=nueva_reserva
    )
    
    return {"message": "Reserva creada", "booking": nueva_reserva}
```

---

## 🎨 PLANTILLAS DE EMAILS

### Emails que debes enviar:

1. **Confirmación de Reserva** ✅
   - Al cliente: "Tu reserva está confirmada"
   - Al admin: "Nueva reserva recibida"

2. **Asignación de Conductor** 🚗
   - Al cliente: "Tu conductor ha sido asignado"
   - Con datos del conductor

3. **Viaje Completado** ✅
   - Al cliente: "Gracias por viajar con nosotros"
   - Pedir calificación

4. **Cancelación** ❌
   - Al cliente: "Tu reserva ha sido cancelada"
   - Política de cancelación

---

## 💰 COSTOS

**SendGrid Gratis:**
- 100 emails/día
- Suficiente para ~3,000 emails/mes
- Equivalente a ~100 reservas/día

**Si necesitas más:**
- Essentials: $19.95/mes (50,000 emails)
- Pro: $89.95/mes (100,000 emails)

---

## 🔒 SEGURIDAD

**Variables de entorno necesarias:**
```
SENDGRID_API_KEY=SG.xxxxx
VANELUX_FROM_EMAIL=noreply@vanelux.com
VANELUX_ADMIN_EMAIL=admin@vanelux.com
```

**Configurar en Railway:**
1. Dashboard → Variables
2. Agregar cada variable
3. Redesplegar

---

## 🧪 TESTING

Probar localmente:
```python
python
>>> from services.email_service import email_service
>>> email_service.enviar_confirmacion_reserva(
...     "tu-email@gmail.com",
...     "Test User",
...     {"id": "123", "pickup_address": "NYC", "total_price": 150}
... )
```

---

## 📊 ALTERNATIVAS

| Servicio | Emails Gratis/mes | Precio después | Recomendado para |
|----------|-------------------|----------------|------------------|
| **SendGrid** | 3,000 | $19.95/50k | ⭐ Startups |
| **Resend** | 3,000 | $20/50k | Desarrolladores |
| **Mailgun** | 1,500 | $35/50k | Empresas |
| **Gmail SMTP** | 15,000 | Gratis | Testing |

---

¿Quieres que implemente el código completo en tu backend? 🚀
