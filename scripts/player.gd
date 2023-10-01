extends CharacterBody2D
@onready var main = get_tree().get_root().get_node("main")

signal someone_attack_me_help(damage)

const SPEED = 600.0
const FRICTION = 0.1

var viewport
var camera

var current_dir = Vector2(1, 0)
var is_running = false

@export var audio_stream: AudioStream
@export var max_attack_dmg:float = 10
@export var healing_time:float = 30
@export var max_health:float = 100
@export var max_stamina:float = 100
var attack_dmg:float
var health:float = 100
var stamina:float = 100
var is_exhausted = false
var furious:bool = false
var tomb_raider:bool = false

func _ready():
	health = max_health
	stamina = max_stamina
	
	viewport = get_viewport()
	camera = viewport.get_camera_2d()
	
	attack_dmg = max_attack_dmg / $flashlight.get_child_count()
	someone_attack_me_help.connect(on_being_attacked)
	$healing_timer.wait_time = healing_time
	$healing_timer.timeout.connect(heal)

func walking_sound():
	var ASP = AudioStreamPlayer2D.new()
	main.add_child(ASP)
	ASP.stream = audio_stream
	ASP.global_position = global_position
	ASP.finished.connect(ASP.queue_free)
	ASP.play()

func heal():
	health = clamp(health + 5, 0, max_health)

func on_being_attacked(damage):
	health -= damage
	if health <= 0:
		$"../../main".died.emit()

func _physics_process(delta):
	if health <= 0: return

	var dir = Vector2.ZERO
	var speed_multiplier = 1
	if Input.is_action_pressed("up"):
		dir += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		dir += Vector2(0, 1)
	if Input.is_action_pressed("left"):
		dir += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		dir += Vector2(1, 0)
	is_running = Input.is_action_pressed("run")
	dir = dir.normalized()
	
	if is_exhausted:
		is_running = false
		speed_multiplier = clamp((stamina + 10) / max_stamina, 0, 1)
	if is_running:
		speed_multiplier = 2.5
	velocity += dir.normalized() * SPEED * speed_multiplier * delta

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
		
	if dir == Vector2.ZERO or !is_running or furious:
		look_at(viewport.get_mouse_position())
	else:
		current_dir = current_dir.lerp(dir, 0.5)
		look_at(current_dir + position)
	rotation += PI
	
	# after rotate, check if can attack
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
	
	$walksound_delay.wait_time = clamp(1 / speed_multiplier * 0.4, 0, 1.5)
	if dir != Vector2.ZERO:
		if $walksound_delay.is_stopped():
			walking_sound()
			$walksound_delay.start()
		
	velocity *= 1 - FRICTION

	move_and_slide()
