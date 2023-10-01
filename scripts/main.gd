extends Node2D

signal died

var rng = RandomNumberGenerator.new()

@export var foe_spawn_delay:float = 1
@onready var foe_model = preload("res://scenes/foe.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	died.connect(show_death_screen)
	$death_UI/Button.button_down.connect(replay)
	
	$foe_spawn_timer.wait_time = foe_spawn_delay
	$foe_spawn_timer.timeout.connect(spawn_foe)

func spawn_foe():
	var foe_instance = foe_model.instantiate()
	var angle = rng.randf_range(-PI, PI)
	var dir = Vector2(cos(angle), sin(angle)) * 200 + $player.position
	foe_instance.position = dir
	$foes.add_child(foe_instance)

func show_death_screen():
	get_tree().paused = true
	$death_UI.visible = true

func replay():
	get_tree().paused = false
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
