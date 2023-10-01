extends Node2D

signal died

var rng = RandomNumberGenerator.new()

@onready var foe_model = preload("res://scenes/foe.tscn")
@onready var block_model = preload("res://scenes/blck.tscn")
var foe_attack_dmg_max:float = 10
var foe_speed_max:float = 900.0
var foe_health_max:float = 100
var foe_attack_cooldown_max:float = 1.5

@export var foe_spawn_delay:float = 1
var foe_spawned:int = 0
var foe_killed:int = 0
var foe_killed_total:int = 0
var current_foe_count_max:int = 15
var wave_count:int = 1

enum FOE_CLASS {RANDOM, BIGASS, ROACH}
enum SKILL {CAT_VISION, STRONGER_LIGHT, LARGER_LIGHT, EXPERT_RUNNER, MEDIC, FURIOUS}

# Called when the node enters the scene tree for the first time.
func _ready():
	died.connect(show_death_screen)
	$death_UI/Button.button_down.connect(replay)
	
	$foe_spawn_timer.wait_time = foe_spawn_delay
	$foe_spawn_timer.timeout.connect(spawn_foe)
	
	$wave_start_timer.timeout.connect(start_wave)

func start_wave():
	$foe_spawn_timer.start()

func increase_diff():
	$foe_spawn_timer.wait_time *= 0.9
	foe_attack_dmg_max *= 1.1
	foe_speed_max *= 1.05
	foe_health_max *= 1.1
	foe_attack_cooldown_max *= 0.95
	current_foe_count_max *= 1.5

func spawn_foe():
	if foe_spawned == current_foe_count_max:
		$foe_spawn_timer.stop()
		return
	
	var foe_instance = foe_model.instantiate()
	var angle = rng.randf_range(-PI, PI)
	var rand_dir = Vector2(cos(angle), sin(angle))
	var dir = rand_dir * 200 + $player.position
	dir.x = clamp(dir.x, 20, 1350)
	dir.y = clamp(dir.y, 20, 750)
	foe_instance.position = dir

	var foe_class = rng.randi_range(0, 2)
	if foe_class == FOE_CLASS.RANDOM:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.5, 1)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.5, 1)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.5, 1)
		foe_instance.attack_cooldown = foe_attack_cooldown_max * rng.randf_range(0.9, 1.1)
	elif foe_class == FOE_CLASS.BIGASS:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.9, 1.3)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.1, 0.4)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.9, 1.7)
		foe_instance.attack_cooldown = foe_attack_cooldown_max * rng.randf_range(0.3, 0.7)
	elif foe_class == FOE_CLASS.ROACH:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.3, 0.5)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(1.5, 2)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.3, 0.7)
	$foes.add_child(foe_instance)
	
	foe_spawned += 1

func show_death_screen():
	get_tree().paused = true
	$death_UI.visible = true

func replay():
	get_tree().paused = false
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$UI/healthbar.max_value = ceil($player.max_health)
	$UI/healthbar.value = ceil($player.health)
	$UI/staminabar.value = $player.stamina
	if $player.is_exhausted:
		$UI/exhausted.text = "Exhausted!"
	else:
		$UI/exhausted.text = ""
	
	if !$wave_start_timer.is_stopped():
		$UI/info.text = "wave start in " + str(floor($wave_start_timer.time_left))
	else:
		$UI/info.text = str(current_foe_count_max - foe_killed) + '/' + str(current_foe_count_max) + " remain"

	if foe_killed == current_foe_count_max:
		foe_killed = 0
		foe_spawned = 0
		increase_diff()
		$wave_start_timer.start()
