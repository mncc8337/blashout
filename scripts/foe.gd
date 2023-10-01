extends CharacterBody2D

signal being_attacked(damage)

var SPEED = 600.0
var health = 100.0
@export var attack_dmg = 10
@export var attack_range = 50 # in px
@export var attack_cooldown = 1.5
@onready var player = $"../../player"

var sqr_attack_range

func _ready():
	$attack_cooldown.wait_time = attack_cooldown
	sqr_attack_range = attack_range * attack_range
	
	being_attacked.connect(receive_damage)

func receive_damage(damage):
	health -= damage
	if health <= 0:
		#do sth before this
		self.queue_free()

func _process(delta):
	$healthbar.visible = health < 100
	$healthbar.value = health

func _physics_process(delta):
	var player_pos = player.global_position
	var a_direction = player_pos - self.global_position
	velocity = a_direction.normalized() * SPEED * delta
	move_and_slide()
	
	# after move check if can attack
	if $attack_cooldown.is_stopped():
		if a_direction.dot(a_direction) < sqr_attack_range:
			player.someone_attack_me_help.emit(attack_dmg)
			$attack_cooldown.start()
