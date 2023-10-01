extends CharacterBody2D

signal someone_attack_me_help(damage)

const SPEED = 600.0
const FRICTION = 0.1

var viewport
var camera

var current_dir = Vector2(1, 0)
var is_running = false

var attack_dmg = 0.5
var health = 100
var stamina = 100
var is_exhausted = false

func _ready():
	viewport = get_viewport()
	camera = viewport.get_camera_2d()
	
	someone_attack_me_help.connect(on_being_attacked)

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
		speed_multiplier = clamp((stamina + 10) / 100, 0, 1)
	if is_running:
		speed_multiplier = 2.5
	velocity += dir.normalized() * SPEED * speed_multiplier * delta
	
	if dir == Vector2.ZERO or speed_multiplier < 0.5:
		if stamina < 100:
			stamina += 0.25
		else:
			is_exhausted = false
	if is_running and dir != Vector2.ZERO:
		if stamina > 0:
			stamina -= 0.5
		else:
			is_exhausted = true
			stamina = 0
		
	if dir == Vector2.ZERO or !is_running:
		look_at(viewport.get_mouse_position() + camera.position)
	else:
		current_dir = current_dir.lerp(dir, 0.5)
		look_at(current_dir + position)
	rotation += PI
	
	# after rotate, check if can attack
	for body in $lightarea.get_overlapping_bodies():
		if body.is_in_group("foe"):
			body.being_attacked.emit(attack_dmg)
	
	velocity *= 1 - FRICTION

	move_and_slide()
