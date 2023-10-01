extends Node2D

signal died

# Called when the node enters the scene tree for the first time.
func _ready():
	died.connect(show_death_screen)
	$death_UI/Button.button_down.connect(replay)

func show_death_screen():
	$death_UI.visible = true

func replay():
	get_tree().paused = false
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
