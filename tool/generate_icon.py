from PIL import Image, ImageDraw

SIZE = 1024
DEEP_PURPLE = (45, 27, 105, 255)
PALE_GOLD = (201, 168, 76, 255)

img = Image.new("RGBA", (SIZE, SIZE), DEEP_PURPLE)
draw = ImageDraw.Draw(img)

center = SIZE // 2
rings = [(0.92, 30), (0.68, 26), (0.44, 0)]

for scale, width in rings:
    radius = int(SIZE * scale / 2)
    bbox = [center - radius, center - radius, center + radius, center + radius]
    if width == 0:
        draw.ellipse(bbox, fill=PALE_GOLD)
    else:
        draw.ellipse(bbox, outline=PALE_GOLD, width=width)

img.save("assets/icon/app_icon.png")
print("Icon saved")
