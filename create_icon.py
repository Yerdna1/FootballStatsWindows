from PIL import Image, ImageDraw

def create_football_icon(size):
    # Create a new image with a white background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw the ball (green circle with white pentagon pattern)
    circle_size = size - 4
    draw.ellipse([2, 2, circle_size, circle_size], fill=(76, 175, 80))  # Green background
    
    # Draw a simplified pentagon pattern in white
    center = size // 2
    radius = (size // 2) - 8
    
    # Draw white pentagon
    points = []
    for i in range(5):
        angle = i * (360 / 5) - 18  # -18 degrees to rotate slightly
        x = center + int(radius * 0.8 * ImageDraw.math.cos(ImageDraw.math.radians(angle)))
        y = center + int(radius * 0.8 * ImageDraw.math.sin(ImageDraw.math.radians(angle)))
        points.append((x, y))
    
    draw.polygon(points, fill=(255, 255, 255))
    
    # Draw black pentagon (smaller)
    points = []
    for i in range(5):
        angle = i * (360 / 5) - 18
        x = center + int(radius * 0.6 * ImageDraw.math.cos(ImageDraw.math.radians(angle)))
        y = center + int(radius * 0.6 * ImageDraw.math.sin(ImageDraw.math.radians(angle)))
        points.append((x, y))
    
    draw.polygon(points, fill=(0, 0, 0))
    
    return img

# Create icons of different sizes
sizes = [16, 32, 48, 256]
images = []

for size in sizes:
    images.append(create_football_icon(size))

# Save as ICO file with multiple sizes
images[3].save('app_icon.ico', format='ICO', sizes=[(16, 16), (32, 32), (48, 48), (256, 256)], append_images=images[:-1])
