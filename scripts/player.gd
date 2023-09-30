extends CharacterBody2D

const SPEED = 100.0
const FRICTION = 0.1

var last_dir = Vector2(1, 0)
var current_dir = Vector2(1, 0)

func sign(x):
	if x < 0:
		return -1
	return 1

func _physics_process(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("up"):
		dir += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		dir += Vector2(0, 1)
	if Input.is_action_pressed("left"):
		dir += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		dir += Vector2(1, 0)
	dir = dir.normalized()
	velocity += dir.normalized() * SPEED
	
	if dir == Vector2.ZERO:
		dir = last_dir
	last_dir = dir
	current_dir = current_dir.lerp(dir, 0.2)
	
	look_at(-current_dir + position)
	
	velocity *= 1 - FRICTION

	move_and_slide()
