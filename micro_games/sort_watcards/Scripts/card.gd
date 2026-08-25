extends Control


@export var real := true
@export var target_position := Vector2(1673, 800)

var interactable = true
var hovered = false
var holding = false
var held_mouse_pos := Vector2(0, 0)
var prev_mouse_pos = null
var prev_timestamp = 0

var target_pos = null
var offset := Vector2(0,0)

var velocity := Vector2(0, 0)

var correct_sort := true
var exhausted = false


signal sorted(real: bool, correct: bool)

#follow mouse slgihtly behind and rotate towards direction (like balatro)
#if flick is registered, calculate angle and put in corresponding pile

#when flicked, have card spin in circles and land in the pile at any possible angle
#include a thud in the tween when it lands

# Called when the node enters the scene tree for the first time.
func _ready():
	interactable = true
	pivot_offset = size/2


func _on_mouse_entered() -> void:
	if !interactable: return
	hovered = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.06)


func _on_mouse_exited() -> void:
	if !interactable: return
	hovered = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.06)
		
func _input(event):
	if !interactable: return
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and holding:
		prev_mouse_pos = held_mouse_pos
		held_mouse_pos = event.position
		target_pos += held_mouse_pos - prev_mouse_pos

	elif event is InputEventMouseButton:
		held_mouse_pos = event.position
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and hovered:
			holding = true
			target_pos = self.position
			offset = held_mouse_pos - target_pos
		elif holding:
			holding = false
			if prev_mouse_pos != null:
				#Check if we satisfy flick condition
				if (held_mouse_pos - (self.position + offset)).length() > 90:
					flick()

func flick() -> void:
	disable_interaction()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	#Toss fakes to the right, real to the left
	correct_sort = (held_mouse_pos - (self.position + offset)).x > 0 == !real
	print(correct_sort)
	
	var angle = clamp(
	Vector2(0, -1).angle_to(held_mouse_pos - self.position + offset),
	0.0,
	PI / 2.0
)
	print("ANGLE TO: ", rad_to_deg(angle))
	velocity = calculate_velocity(self.position, target_position, 90-angle, 2500)
	velocity = (held_mouse_pos - (self.position + offset)) * 2.5
	
func calculate_velocity(start: Vector2, target: Vector2, angle: float, gravity: float) -> Vector2:
	var dx := target.x - start.x
	var dy := target.y - start.y

	var vx := dx * sqrt(
		gravity / (2.0 * (dx * tan(angle) + dy))
	)

	var vy := -vx * tan(angle)

	var velocity := Vector2(vx, vy)
	print(velocity)
	return velocity


func disable_interaction() -> void:
	interactable = false
	hovered = false
	holding = false
	
func _process(delta: float) -> void:
	if interactable and target_pos != null:
		var new_pos = position.lerp(target_pos, delta*8)
		var vel = new_pos.distance_to(self.position) * delta
		if new_pos.x > self.position.x:
			self.rotation = vel * 0.5
		else:
			self.rotation = vel * -0.5
		self.position = new_pos
	
	if (!interactable):
		self.position += velocity * delta
		velocity.y += 2500 * delta
		self.rotation += 9 * delta if velocity.x > 0 else -9 * delta
		
	if self.position.x < 0 or self.position.x > 1920 or self.position.y < 0 or self.position.y > 1080:
		if !exhausted:
			sorted.emit((!real && correct_sort) || (real && !correct_sort), correct_sort)
			exhausted = true
	
