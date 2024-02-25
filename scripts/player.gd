extends CharacterBody2D

signal died
const FRICTION = 0.1

@onready var viewport = get_viewport()
@onready var camera = viewport.get_camera_2d()

var current_dir = Vector2(1, 0)
var is_running = false

@export var move_joystick: TouchScreenButton
@export var dir_joystick:  TouchScreenButton
@export var main: Node

@export var SPEED: float          = 600.0
@export var audio_stream: AudioStream
@export var max_attack_dmg: float = 10
@export var healing_time: float   = 20
@export var max_health: float     = 100
@export var max_stamina: float    = 100
var attack_dmg: float
var health: float     = 100
var stamina: float    = 100
var is_exhausted      = false
var furious: bool     = false
var tomb_raider: bool = false

func _ready():
	health = max_health
	stamina = max_stamina
	
	attack_dmg = max_attack_dmg / $flashlight.get_child_count()
	$healing_timer.wait_time = healing_time
	$healing_timer.timeout.connect(heal)

func walking_sound():
	var ASP = AudioStreamPlayer.new()
	main.add_child(ASP)
	ASP.volume_db = -15
	ASP.pitch_scale = 1.0
	ASP.stream = audio_stream
	ASP.finished.connect(ASP.queue_free)
	ASP.play()

func heal():
	health = clamp(health * 1.05, 0, max_health)

func deal_dmg(damage):
	health -= damage
	if health <= 0:
		died.emit()

func check_attack():
	for ray in $flashlight.get_children():
		var objects_collide = []
		while ray.is_colliding():
			var obj = ray.get_collider()
			if obj == null:
				break
			if obj.is_in_group("foe"):
				objects_collide.append(obj)
				ray.add_exception(obj)
				ray.force_raycast_update()
			else:
				if obj.is_in_group("grave") and tomb_raider:
					objects_collide.append(obj)
				break
		var dmg_multiplier = 1
		for obj in objects_collide:
			obj.being_attacked.emit(attack_dmg * dmg_multiplier)
			ray.remove_exception(obj)
			dmg_multiplier *= 0.9

func _physics_process(delta):
	if health <= 0: return

	var dir = Vector2.ZERO
	var speed_multiplier = 1
	
	if not main.mobile:
		if Input.is_action_pressed("up"):
			dir += Vector2(0, -1)
		if Input.is_action_pressed("down"):
			dir += Vector2(0, 1)
		if Input.is_action_pressed("left"):
			dir += Vector2(-1, 0)
		if Input.is_action_pressed("right"):
			dir += Vector2(1, 0)
		dir = dir.normalized()
	elif move_joystick.is_pressed():
		dir = move_joystick.direction
	
	is_running = Input.is_action_pressed("run")
	
	if is_exhausted:
		is_running = false
		speed_multiplier = clamp((stamina + 10) / max_stamina, 0, 1)
	if is_running:
		speed_multiplier = 3 + stamina / max_stamina * 2
	velocity += dir * SPEED * speed_multiplier * delta
	
	$walksound_delay.wait_time = clamp(1 / speed_multiplier * 0.4, 0, 1.5)
	if dir != Vector2.ZERO:
		if $walksound_delay.is_stopped():
			walking_sound()
			$walksound_delay.start()
		
	velocity *= 1 - FRICTION

	move_and_slide()

	# stamina
	if dir == Vector2.ZERO or speed_multiplier < 0.5:
		if stamina < max_stamina:
			stamina = clamp(stamina + 0.25, 0, max_stamina)
		else:
			is_exhausted = false
	if is_running and dir != Vector2.ZERO:
		if stamina > 0:
			stamina -= 0.5
		else:
			is_exhausted = true
			stamina = 0
	
	if not main.mobile:
		if dir == Vector2.ZERO or !is_running or furious:
			var rat = (viewport.get_size() * 1.0 - Vector2(1366, 768))
			look_at(viewport.get_mouse_position() - rat / 2) # idk why but it works lol
		else:
			current_dir = current_dir.lerp(dir, 0.5)
			look_at(current_dir + position)
		rotation += PI
	elif dir_joystick.is_pressed():
		var d = dir_joystick.direction.normalized()
		if d.y < 0:
			rotation = -acos(d.x)
		else:
			rotation = acos(d.x)
		rotation += PI

	# after rotate, check if can attack	
	check_attack()
