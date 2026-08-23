extends MicroGame


@onready var butter_painter = %ButterTexture
@onready var progress_bar = %ButteredProgress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	start.connect(_on_start)


func _on_start() -> void:
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	butter_painter.toast_buttered.connect(_on_toast_buttered)

func _on_toast_buttered(percentage: float) -> void:
	percentage *= 1.15
	progress_bar.value = percentage * 100.0
	if (percentage >= 1):
		win.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
