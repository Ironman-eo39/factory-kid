class_name FaceDecal
extends RefCounted
## Procedural cartoon-face textures for the face-decal quad.
## Expressions: "happy" (default), "angry", "dizzy", "tung" (big-eyed smile).
## 128x128 RGBA; white kept transparent via material alpha.


const SIZE := 128
const INK := Color(0.05, 0.05, 0.05, 1.0)
const WHITE := Color(1, 1, 1, 1.0)


static func make_texture(expression: String) -> ImageTexture:
	var img := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match expression:
		"angry":
			_eyes(img)
			_brows(img)
			_line(img, 46, 98, 82, 98, 7, INK)
		"dizzy":
			_x_eyes(img)
			_circle_outline(img, 64, 96, 11, 6, INK)
		"tung":
			_tung_face(img)
		_:
			_eyes(img)
			_smile(img)
	return ImageTexture.create_from_image(img)


static func _tung_face(img: Image) -> void:
	# huge close-set eyes, long nose, wide friendly smile
	for cx in [50, 78]:
		_circle_fill(img, cx, 42, 20, WHITE)
		_circle_fill(img, cx, 46, 10, INK)
		_circle_fill(img, cx - 4, 42, 4, WHITE)
	_line(img, 64, 56, 64, 78, 6, INK)
	for deg in range(15, 166, 2):
		var rad := deg_to_rad(float(deg))
		var x := int(64.0 + 32.0 * cos(rad))
		var y := int(66.0 + 32.0 * sin(rad))
		_circle_fill(img, x, y, 4, INK)


static func _eyes(img: Image) -> void:
	for cx in [44, 84]:
		_circle_fill(img, cx, 50, 17, WHITE)
		_circle_fill(img, cx, 54, 8, INK)
		_circle_fill(img, cx - 3, 51, 3, WHITE)


static func _brows(img: Image) -> void:
	_line(img, 28, 26, 58, 40, 9, INK)
	_line(img, 100, 26, 70, 40, 9, INK)


static func _x_eyes(img: Image) -> void:
	for cx in [44, 84]:
		_line(img, cx - 12, 38, cx + 12, 62, 7, INK)
		_line(img, cx + 12, 38, cx - 12, 62, 7, INK)


static func _smile(img: Image) -> void:
	# lower arc of a circle centered above the mouth
	for deg in range(25, 156, 2):
		var rad := deg_to_rad(float(deg))
		var x := int(64.0 + 24.0 * cos(rad))
		var y := int(74.0 + 24.0 * sin(rad))
		_circle_fill(img, x, y, 4, INK)


static func _circle_fill(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			if x < 0 or y < 0 or x >= SIZE or y >= SIZE:
				continue
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= r * r:
				img.set_pixel(x, y, c)


static func _circle_outline(img: Image, cx: int, cy: int, r: int, w: int, c: Color) -> void:
	for y in range(cy - r - w, cy + r + w + 1):
		for x in range(cx - r - w, cx + r + w + 1):
			if x < 0 or y < 0 or x >= SIZE or y >= SIZE:
				continue
			var d := sqrt(float((x - cx) * (x - cx) + (y - cy) * (y - cy)))
			if absf(d - float(r)) <= float(w) * 0.5:
				img.set_pixel(x, y, c)


static func _line(img: Image, x0: int, y0: int, x1: int, y1: int, w: int, c: Color) -> void:
	var steps := maxi(abs(x1 - x0), abs(y1 - y0))
	if steps == 0:
		_circle_fill(img, x0, y0, w / 2, c)
		return
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var x := int(lerpf(float(x0), float(x1), t))
		var y := int(lerpf(float(y0), float(y1), t))
		_circle_fill(img, x, y, w / 2, c)
