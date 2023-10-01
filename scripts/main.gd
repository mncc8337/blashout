extends Node2D

signal died

var rng = RandomNumberGenerator.new()

@export var difficulty_time:float = 30
@export var foe_spawn_delay:float = 1
@onready var foe_model = preload("res://scenes/foe.tscn")
var foe_attack_dmg_max:float = 10
var foe_speed_max:float = 600.0
var foe_health_max:float = 100

enum FOE_CLASS {RANDOM, BIGASS, ROACH}

# Called when the node enters the scene tree for the first time.
func _ready():
	died.connect(show_death_screen)
	$death_UI/Button.button_down.connect(replay)
	
	$foe_spawn_timer.wait_time = foe_spawn_delay
	$foe_spawn_timer.timeout.connect(spawn_foe)
	
	$difficulty_timer.wait_time = difficulty_time
	$difficulty_timer.timeout.connect(increase_diff)

func increase_diff():
	$foe_spawn_timer.wait_time *= 0.9
	foe_attack_dmg_max *= 1.1
	foe_speed_max *= 1.1
	foe_health_max *= 1.1

func spawn_foe():
	var foe_instance = foe_model.instantiate()
	var angle = rng.randf_range(-PI, PI)
	var dir = Vector2(cos(angle), sin(angle)) * 200 + $player.position
	foe_instance.position = dir
	var foe_class = rng.randi_range(0, 2)
	if foe_class == FOE_CLASS.RANDOM:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.5, 1)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.5, 1)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.5, 1)
		print("spawned a random foe")
	elif foe_class == FOE_CLASS.BIGASS:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.9, 1.3)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.1, 0.4)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.9, 1.7)
		print("spawned a big ass foe")
	elif foe_class == FOE_CLASS.ROACH:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.3, 0.7)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(1.5, 2)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.3, 0.7)
		print("spawned a roach foe")
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
