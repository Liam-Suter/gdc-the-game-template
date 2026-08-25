extends Control

const GameSFX = preload("res://micro_games/butter_toast/Scripts/game_sfx.gd")

var hovered := false
var holding := false
var held_mouse_pos := Vector2(0, 0)
@onready var butter1 = %Butter1
@onready var butter2 = %Butter2
@onready var butter3 = %Butter3
@onready var butter4 = %Butter4
@onready var butter_particles1 = %ButterParticles1
@onready var butter_particles2 = %ButterParticles2

signal knife_moved(points: Array[Vector2])

func _ready():
	pivot_offset = size/2

func _on_mouse_entered() -> void:
	hovered = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.06)


func _on_mouse_exited() -> void:
	hovered = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.06)
		
func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and holding:
		position += event.position - held_mouse_pos
		held_mouse_pos = event.position
		var point_array: Array[Vector2] = [butter1.global_position, butter2.global_position, butter3.global_position, butter4.global_position]
		knife_moved.emit(point_array)

	elif event is InputEventMouseButton and hovered:
		held_mouse_pos = event.position
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			holding = true
			GameSFX.play(self, "res://micro_games/butter_toast/Assets/knife_pickup.wav", -1)
			butter_particles1.emitting = true
			butter_particles2.emitting = true
		else:
			holding = false
			GameSFX.play(self, "res://micro_games/butter_toast/Assets/knife_drop.wav", 0)
			butter_particles1.emitting = false
			butter_particles2.emitting = false
		


func _on_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
