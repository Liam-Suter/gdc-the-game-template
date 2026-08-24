extends TextureRect

var hovered := false
var held_mouse_pos := Vector2(0, 0)
@onready var butter1 = %Butter1
@onready var butter2 = %Butter2
@onready var butter3 = %Butter3
@onready var butter4 = %Butter4

signal knife_moved(points: Array[Vector2])

func _ready():
	pivot_offset = size/2

func _on_hover_enter() -> void:
	print("HOVER")


func _on_mouse_entered() -> void:
	hovered = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.06)


func _on_mouse_exited() -> void:
	hovered = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.75, 0.75), 0.06)
		
func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position += event.position - held_mouse_pos
		held_mouse_pos = event.position
		var point_array: Array[Vector2] = [butter1.global_position, butter2.global_position, butter3.global_position, butter4.global_position]
		knife_moved.emit(point_array)

	elif event is InputEventMouseButton:
		held_mouse_pos = event.position
