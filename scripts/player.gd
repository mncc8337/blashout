extends CharacterBody2D

const SPEED = 100.0
const FRICTION = 0.1

var dir = Vector2.ZERO
var last_rot = 0.0

func sign(x):
	if x < 0:
		return -1
	return 1

func _physics_process(delta):
	if Input.is_action_pressed("up"):
		velocity.y -= SPEED
		dir += Vector2(0, -1)
	if Input.is_action_pressed("down"):
		velocity.y += SPEED
		dir += Vector2(0, 1)
	if Input.is_action_pressed("left"):
		velocity.x -= SPEED
		dir += Vector2(-1, 0)
	if Input.is_action_pressed("right"):
		velocity.x += SPEED
		dir += Vector2(1, 0)
	
	var move_on_x = Input.is_action_pressed("left") or Input.is_action_pressed("right")
	var move_on_y = Input.is_action_pressed("up") or Input.is_action_pressed("down")
	
	var new_rot_y = 180 + 90 * sign(velocity.y)
	var new_rot_x = 90 + 90 * sign(velocity.x)
	var new_rot = new_rot_x * int(move_on_x) + new_rot_y * int(move_on_y)
	if move_on_x and move_on_y:
		new_rot /= 2

	var current_rot = rotation_degrees

	if not move_on_x and not move_on_y:
		new_rot = last_rot

	if Input.is_action_pressed("down") and Input.is_action_pressed("left"):
		new_rot += 180
	if current_rot <= 0 and current_rot > -180 and new_rot >= 0 and new_rot <= 90:
		new_rot += 360.0
	if current_rot < 90 and current_rot >= 0 and new_rot >= 270 and new_rot <= 360:
		new_rot -= 360.0
		
	last_rot = new_rot

	if current_rot < 0:
		current_rot += 360
	current_rot = lerp(current_rot, new_rot, 0.35)
	print(current_rot)
	rotation_degrees = current_rot
	
	velocity *= 1 - FRICTION

	move_and_slide()
