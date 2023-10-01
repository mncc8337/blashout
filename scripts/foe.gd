extends CharacterBody2D


var SPEED = 600.0
var V = Vector2.ZERO
@onready var player = $"../../player"

func _physics_process(delta):
	var player_pos = player.global_position
	move_to(player_pos, delta)

func move_to(f_target, delta):
	var a_direction = (f_target - self.global_position).normalized()
	velocity = a_direction * SPEED * delta
	#if a_direction.x > 0:
	# 	self.global_transform.x = Vector2(-3,0)
	# else: self.global_transform.x = Vector2(3,0)
	move_and_slide()
