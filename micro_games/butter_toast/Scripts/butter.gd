extends TextureRect

@export var mask_size := Vector2i(512, 512)
@export var butter_size := Vector2i(530, 530)
@export var top_left_corner := Vector2i(111, 44)
@export var brush_radius := 20

var mask_image: Image
var mask_texture: ImageTexture

var prev_butter_positions: Array[Vector2]

var pixel_count: int
var total_pixels: int

signal toast_buttered(percentage: float)

@onready var butter_mat = material as ShaderMaterial
@onready var butter = %ButterTexture
@onready var butter_particles1 = %ButterParticles1
@onready var butter_particles2 = %ButterParticles2
@onready var knife = %Knife

func _ready():
	butter_particles1.emitting = false;
	butter_particles2.emitting = false;
	prev_butter_positions.clear()
	total_pixels = butter_size.x * butter_size.y
	# Start completely black
	mask_image = Image.create(
		mask_size.x,
		mask_size.y,
		false,
		Image.FORMAT_RGBA8
	)
	mask_image.fill(Color.BLACK)

	mask_texture = ImageTexture.create_from_image(mask_image)
	
	knife.knife_moved.connect(_on_knife_moved)
	
	if butter_mat != null:
		butter_mat.set_shader_parameter("mask_texture", mask_texture)

func _input(event):		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			prev_butter_positions.clear()
			
func _on_knife_moved(points: Array[Vector2]):
	var prev_exists = !prev_butter_positions.is_empty()
	
	for i in range(points.size()):
		var point = points[i]
		
		if i == 0: butter_particles1.position = point
		if i == 2: butter_particles2.position = point
		
		point = point - position #localize
		if (prev_exists):
			paint_mask(point, prev_butter_positions[i])
			prev_butter_positions[i] = point
		else:
			paint_mask(point, Vector2(-100, -100))
			prev_butter_positions.push_back(point)

func paint_mask(local_pos: Vector2, prev_pos: Vector2):
	# Convert screen position to mask pixel coordinates.
	var pixels_added = false
	var point_array = []
	point_array.append(local_pos)
	if (prev_pos != Vector2(-100, -100)):
		var dist = prev_pos.distance_to(local_pos)
		var i = dist
		while (i >= brush_radius):
			point_array.append(prev_pos.lerp(local_pos, i/dist))
			
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

				if px >= top_left_corner.x and px < top_left_corner.x + butter_size.x and py >= top_left_corner.y and py < top_left_corner.y + butter_size.y:
					var col: Color = mask_image.get_pixel(px, py)
					if col != Color.WHITE:
						mask_image.set_pixel(px, py, Color.WHITE)
						pixel_count += 1
						pixels_added = true

	# Push modified image to GPU texture
	if pixels_added:
		mask_texture.update(mask_image)
		toast_buttered.emit(float(pixel_count) / float(total_pixels))
	
	
