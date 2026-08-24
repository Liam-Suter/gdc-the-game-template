extends MicroGame

const GameSFX = preload("res://micro_games/midnight_deadline/Scripts/game_sfx.gd")

@export var grab_hand_pos := Vector2(0, 0)

@onready var butter_painter = %ButterTexture
@onready var progress_bar = %ButteredProgress
@onready var butter_bar = %ButterBar
@onready var hand = %Hand
@onready var thumb = %Thumb

@onready var butter_particles = %EatingButterParticles
@onready var dry_particles = %EatingDryParticles
@onready var spit_particles = %SpittingDryParticles

var minigame_active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	start.connect(_on_start)
	
	win.connect(_on_win)
	lose.connect(_on_lose)


func _on_start() -> void:
	minigame_active = true
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	butter_painter.toast_buttered.connect(_on_toast_buttered)

func _on_toast_buttered(percentage: float) -> void:
	percentage *= 1.15
	progress_bar.value = percentage * 100.0
	butter_bar.position.y = progress_bar.position.y + clamp((1 - percentage), 0, 1) * progress_bar.size.y
	if (percentage >= 1 && minigame_active):
		win.emit()
		
func _on_win() -> void:
	minigame_active = false
	grab_toast(true)
	
func grab_toast(buttered: bool):
	var tween1 := create_tween()
	tween1.tween_property(hand, "global_position", grab_hand_pos, 0.7).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	var tween2 := create_tween()
	tween2.tween_property(thumb, "global_position", grab_hand_pos, 0.74).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	var pull_back_timer := get_tree().create_timer(0.8)
	pull_back_timer.timeout.connect(func():
		tween1 = create_tween()
		tween1.tween_property(hand, "global_position", Vector2(grab_hand_pos.x, hand.position.y + 900), 1.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.02).timeout
		tween2 = create_tween()
		var tween3 := create_tween()
		tween2.tween_property(thumb, "global_position", Vector2(grab_hand_pos.x, thumb.position.y + 900), 1.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween3.tween_property(butter_painter, "global_position", Vector2(butter_painter.global_position.x, butter_painter.position.y + 900), 1.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	)
		
	var eat_timer = get_tree().create_timer(1.5)
	eat_timer.timeout.connect(func():
		if (buttered):
			pass
			#Normal eating sounds with buttery particles bottom of screen
			butter_particles.emitting = true
			GameSFX.play(self, "res://micro_games/butter_toast/Assets/butter_eat.wav", 0.0)
		else:
			pass
			#Normal eating but then spit and black/brown particles spray out from bottom
			dry_particles.emitting = true
			GameSFX.play(self, "res://micro_games/butter_toast/Assets/crunch.wav", 0.0)
			await get_tree().create_timer(1).timeout
			dry_particles.emitting = false
			await get_tree().create_timer(0.27).timeout
			spit_particles.emitting = true
			GameSFX.play(self, "res://micro_games/butter_toast/Assets/spit.wav", 0.0)
	)
	
	
func _on_lose() -> void:
	minigame_active = false
	grab_toast(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
