extends CharacterBody2D

signal being_attacked(damage)

var SPEED = 600.0
@export var max_health:float = 100
var health = 100.0
@export var attack_dmg = 10
@export var attack_range = 50 # in px
@export var attack_cooldown = 1.5
@onready var player = $"../../player"

var sqr_attack_range

func _ready():
	health = max_health
	
	$attack_cooldown.wait_time = attack_cooldown
	sqr_attack_range = attack_range * attack_range
	
	being_attacked.connect(receive_damage)

func receive_damage(damage):
	health -= damage
	if health <= 0:
		#do sth before this
		var main = $"../../../main"
		var rnd = main.rng.randi_range(1, 100)
		if rnd < 10:
			var block_instance = main.block_model.instantiate()
			block_instance.position = position
			main.add_child(block_instance)
		self.queue_free()

func _process(delta):
	$healthbar.visible = health < max_health
	$healthbar.value = health

func _physics_process(delta):
	var player_pos = player.global_position
	var a_direction = player_pos - self.global_position
	velocity = a_direction.normalized() * SPEED * delta

	#flips foes' sprite based on player position
	if a_direction.x > 0:
		$Sprite2D.global_transform.x = Vector2(-3,0)
	else:
		$Sprite2D.global_transform.x = Vector2(3,0)
	move_and_slide()
	
	# after move check if can attack
	if $attack_cooldown.is_stopped():
		if a_direction.dot(a_direction) < sqr_attack_range:
			player.someone_attack_me_help.emit(attack_dmg)
			$attack_cooldown.start()
