extends CanvasLayer

func start_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func quit_game():
	get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	$VBoxContainer/play.button_down.connect(start_game)
	$VBoxContainer/quit.button_down.connect(quit_game)
