extends MicroGame

const GameSFX = preload("res://micro_games/butter_toast/Scripts/game_sfx.gd")

var mc_lovin = preload("res://micro_games/sort_watcards/FakeWatcards/McLovinFake.tscn")
var laurier = preload("res://micro_games/sort_watcards/FakeWatcards/Fake.tscn")
var real = preload("res://micro_games/sort_watcards/RealWatcards/Real.tscn")

var fake_cards = [mc_lovin, laurier]
var real_cards = [real]

@onready var real_flash := %RealFlash.material as ShaderMaterial
@onready var fake_flash := %FakeFlash.material as ShaderMaterial

var minigame_active := false
var num_cards_sorted := 0
var spawn_locs := [Vector2(670, 81), Vector2(950, 547), Vector2(1117, 319), Vector2(596, 316), Vector2(1199, 59), Vector2(212, 59), Vector2(395, 593), Vector2(117, 321), Vector2(801, 114)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	start.connect(_on_start)
	
	win.connect(_on_win)
	lose.connect(_on_lose)

func _on_start() -> void:
	num_cards_sorted = 0
	minigame_active = true
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var inst_spawn_locs = spawn_locs.duplicate()
	for i in range(inst_spawn_locs.size()):
		var index = randi_range(0, inst_spawn_locs.size()-1)
		var inst
		
		if (randi_range(0, 1) == 0):
			pass
			inst = fake_cards[randi_range(0, fake_cards.size()-1)].instantiate()
		else:
			inst = real_cards[randi_range(0, real_cards.size()-1)].instantiate()
		
		if inst != null:
			add_child(inst)
			inst.position = inst_spawn_locs[index]
			inst.position.x += (randf() - 0.5) * 55
			inst.position.y += (randf() - 0.5) * 45
			inst.sorted.connect(_on_card_sorted)
			inst_spawn_locs.remove_at(index)
		
	
	%RealFlash.material = fake_flash.duplicate()
	real_flash = %RealFlash.material
	
	real_flash.set_shader_parameter("intensity", 0)
	fake_flash.set_shader_parameter("intensity", 0)

func _on_card_sorted(left: bool, correct: bool) -> void:	
	if left:
		flash(real_flash, correct)
	else:
		flash(fake_flash, correct)
		
	if !correct && minigame_active:
		lose.emit()
		minigame_active = false
		
	if correct && minigame_active:
		num_cards_sorted += 1
		print(num_cards_sorted)
		if num_cards_sorted == 9:
			win.emit()
			minigame_active = false
	

func flash(mat: ShaderMaterial, correct: bool) -> void:
	var time = 0
	
	mat.set_shader_parameter("color", Vector3(0, 1, 0) if correct else Vector3(1, 0, 0))
	
	while (time < 0.25):
		mat.set_shader_parameter("intensity", 0.12 * pow(sin(1 + time*6), 15))
		await get_tree().process_frame
		time += get_process_delta_time()
	mat.set_shader_parameter("intensity", 0)

func _on_win() -> void:
	minigame_active = false
	
func _on_lose() -> void:
	minigame_active = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
