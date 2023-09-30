extends CharacterBody2D

const SPEED = 100.0
const FRICTION = 0.1

func _physics_process(delta):
	if Input.is_action_pressed("up"):
		velocity.y -= SPEED
	if Input.is_action_pressed("down"):
		velocity.y += SPEED
	if Input.is_action_pressed("left"):
		velocity.x -= SPEED
	if Input.is_action_pressed("right"):
		velocity.x += SPEED
	
	velocity *= 1 - FRICTION

	move_and_slide()
