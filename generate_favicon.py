"""
Genera favicon.png con el logo de Vanelux
Solo requiere: pip install pillow
"""
from PIL import Image, ImageDraw, ImageFont

# Crear imagen 32x32 con fondo transparente
size = 32
img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Colores Vanelux
navy = (11, 50, 84)     # #0B3254
gold = (212, 175, 55)   # #D4AF37

# Círculo azul marino de fondo
draw.ellipse([0, 0, size-1, size-1], fill=navy)

# Anillo dorado (grosor 2px)
draw.ellipse([2, 2, size-3, size-3], outline=gold, width=2)

# Letra "V" dorada en el centro
try:
    # Intentar usar una fuente serif
    font = ImageFont.truetype("georgia.ttf", 22)
except:
    try:
        font = ImageFont.truetype("times.ttf", 22)
    except:
        # Fallback a fuente por defecto
        font = ImageFont.load_default()

# Dibujar "V" centrada
text = "V"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (size - text_width) // 2 - 1
y = (size - text_height) // 2 - 2

draw.text((x, y), text, fill=gold, font=font)

# Guardar
img.save('web/favicon.png', 'PNG')
print("✅ favicon.png generado correctamente (32x32px)")
