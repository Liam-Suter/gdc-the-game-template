extends Node

@export var decay: float = 0.8
@export var modifier: float = 1

var intensity: float = 0
var static_intensity: float = 0
var prev_offset = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_intensity(amount: float) -> void:
	intensity += amount

func set_static_intensity(value: float) -> void:
	static_intensity = value

func convert_static_to_dynamic() -> void:
	intensity += static_intensity
	static_intensity = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if prev_offset != null:
			self.position -= prev_offset
			prev_offset = null
	
	if intensity + static_intensity > 0:
		var shake_value = pow(intensity, 3) + pow(static_intensity, 3)
		var new_offset = Vector2(randf(), randf()) * shake_value * modifier
		self.position += new_offset
		prev_offset = new_offset
		
		intensity -= decay * delta
		if intensity <= 0:
			intensity = 0
		
		
		
