extends TextureRect

@export var mask_size := Vector2i(512, 512)
@export var brush_radius := 20

var mask_image: Image
var mask_texture: ImageTexture

var prev_mouse_pos: Vector2

var pixel_count: int
var total_pixels: int

signal toast_buttered(percentage: float)

@onready var butter_mat = material as ShaderMaterial
@onready var butter = %ButterTexture
@onready var butter_particles = %ButterParticles

func _ready():
	butter_particles.emitting = false;
	prev_mouse_pos = Vector2(-100, -100)
	total_pixels = mask_size.x * mask_size.y
	print("SCRIPT IS RUNNING")
	# Start completely black
	mask_image = Image.create(
		mask_size.x,
		mask_size.y,
		false,
		Image.FORMAT_RGBA8
	)
	mask_image.fill(Color.BLACK)

	mask_texture = ImageTexture.create_from_image(mask_image)

	
	if butter_mat != null:
		print("Setting param")
		butter_mat.set_shader_parameter("mask_texture", mask_texture)
	else:
		print("N&ULL")
	

func _gui_input(event):
	print("pos: %v", position)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		paint_mask(event.position)
		butter_particles.position = event.position + position

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			prev_mouse_pos = Vector2(-100, -100)
			paint_mask(event.position)
			butter_particles.position = event.position + position
			butter_particles.emitting = true
		else:
			butter_particles.emitting = false


func paint_mask(local_pos: Vector2):
	# Convert screen position to mask pixel coordinates.
	print(local_pos)
	
	var point_array = []
	point_array.append(local_pos)
	if (prev_mouse_pos != Vector2(-100, -100)):
		var dist = prev_mouse_pos.distance_to(local_pos)
		var i = dist
		while (i >= brush_radius):
			point_array.append(prev_mouse_pos.lerp(local_pos, i/dist))
			
			i -= brush_radius

	# Assuming Sprite2D is centered.
	for point in point_array:
		
		var pixel_pos = point

		# Paint a circle of white pixels.
		var radius_sq = brush_radius * brush_radius

		for y in range(-brush_radius, brush_radius + 1):
			for x in range(-brush_radius, brush_radius + 1):
				if x * x + y * y > radius_sq:
					continue

				var px = int(pixel_pos.x) + x
				var py = int(pixel_pos.y) + y

				if px >= 0 and px < mask_size.x and py >= 0 and py < mask_size.y:
					var col: Color = mask_image.get_pixel(px, py)
					if col != Color.WHITE:
						mask_image.set_pixel(px, py, Color.WHITE)
						pixel_count += 1

	# Push modified image to GPU texture
	mask_texture.update(mask_image)
	prev_mouse_pos = local_pos
	toast_buttered.emit(float(pixel_count) / float(total_pixels))
	
	
