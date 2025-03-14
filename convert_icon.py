from cairosvg import svg2png
from PIL import Image
import io

# Read the SVG file
with open('app_icon.svg', 'r') as f:
    svg_content = f.read()

# Convert SVG to PNG in memory
png_data = svg2png(bytestring=svg_content, output_width=256, output_height=256)

# Create PIL Image from PNG data
img = Image.open(io.BytesIO(png_data))

# Convert to ICO
img.save('app_icon.ico', format='ICO', sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])
