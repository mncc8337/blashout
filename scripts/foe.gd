extends CharacterBody2D


var SPEED = 60.0
var V = Vector2.ZERO
#var self_ = $"."
@onready var player = $"../player"

func _physics_process(delta):
	var player_pos = player.global_position
	move(player_pos, delta)

	
func move(f_target, delta):
	var a_direction = (f_target-self.global_position).normalized()
	velocity = a_direction * SPEED
	var delta_v = (velocity-V) * delta 
	velocity+=delta_v
	if a_direction.x > 0:
		self.global_transform.x = Vector2(-3,0)
	else: self.global_transform.x = Vector2(3,0)
	move_and_slide()

