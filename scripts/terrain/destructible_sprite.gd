class_name DestructibleSprite extends Sprite2D

## If the percentage of current pixels covered is less than this value, the fossil is collected.
@export_range(0.0, 1.0) var collect_threshold = 0.1
## If the percentage of original pixels is less below this value, the fossil is unusable.
@export_range(0.0, 1.0) var destroy_threshold = 0.5

var original_pixels : int

var image : Image

var global_rect : Rect2i :
	get: return Rect2i(Vector2i(global_position + get_rect().position), get_rect().size)

var rect : Rect2i:
	get: return get_rect()

var image_rect : Rect2i:
	get: return Rect2i(Vector2i.ZERO, get_rect().size)

var smart_offset : Vector2i:
	get:
		if centered :
			return offset - get_rect().size * 0.5
		return offset

func _init(_image: Image = null) -> void:
	# Texture must be duplicated per instance, so separated instances may be modified independently
	if texture == null : texture = ImageTexture.new()
	else : texture = texture.duplicate(true)

	if _image == null : _image = self.texture.get_image()
	image = _image
	texture.set_image(image)

	original_pixels = get_opaque_pixels()

func _ready() -> void:
	pass

func get_remaining_percent() -> float :
	return float(get_opaque_pixels()) / original_pixels

func get_opaque_pixels() -> int :
	var result : int = 0
	for ix in rect.size.x :
		for iy in rect.size.y :
			if image.get_pixel(ix, iy).a > 0.5 :
				result += 1
	return result

func refresh_texture() -> void :
	texture.set_image(image)

func set_pixels_rect(_rect: Rect2i, value: bool) :
	var sect = global_rect.intersection(_rect)
	var local = sect.position - Vector2i(global_position) - smart_offset
	var ip := Vector2i.ZERO
	for ix in sect.size.x :
		ip.x = local.x + ix
		for iy in sect.size.y :
			ip.y = local.y + iy
			set_pixelv(ip, value)
	refresh_texture()

func set_pixels_circle(origin: Vector2, radius: float, value: bool) :
	var origin_local = Vector2i(origin) - global_rect.position
	var sect = global_rect.intersection(DestructibleSprite.rect_from_circle(origin, radius))
	var local = sect.position - Vector2i(global_position) - smart_offset
	var ip := Vector2i.ZERO
	for ix in sect.size.x :
		ip.x = local.x + ix
		for iy in sect.size.y :
			ip.y = local.y + iy
			var dist = (ip - origin_local).length()
			if dist > radius : continue
			set_pixelv(ip, value)
	refresh_texture()

func set_pixelv(xy: Vector2i, value: bool) -> void:
	var color := image.get_pixelv(xy)
	if value : color.a = 1
	else : color.a = 0
	image.set_pixelv(xy, color)

# func collect() -> void :
# 	print("Collected! (%2.0f percent remaining)" % (get_remaining_percent() * 100))
# 	Terrain.inst.destructibles.erase(self)
# 	queue_free()


# func check_destroy() -> bool:
# 	if get_remaining_percent() < destroy_threshold :
# 		destroy()
# 		return true
# 	return false


# func destroy() -> void :
# 	print("Destroyed!")
# 	Terrain.inst.destructibles.erase(self)
# 	queue_free()


static func rect_from_circle(origin : Vector2i, radius : float) -> Rect2i :
	return Rect2i(origin - Vector2i.ONE * ceili(radius), Vector2i.ONE * ceili(radius) * 2)
