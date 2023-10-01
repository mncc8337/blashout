extends CharacterBody2D

signal being_attacked(damage)

@export var SPEED:float = 600.0
@export var max_health:float = 100
var health:float
@export var attack_dmg:float = 10
@export var attack_range:float = 50 # in px
@export var attack_cooldown:float = 1.5
@onready var player = $"../../player"

var sqr_attack_range

func _ready():
	$healthbar.max_value = max_health
	health = max_health
	
	$attack_cooldown.wait_time = attack_cooldown
	sqr_attack_range = attack_range * attack_range
	
	being_attacked.connect(receive_damage)

func receive_damage(damage):
	health -= damage
	if health <= 0:
		#do sth before this
		self.queue_free()

func _process(delta):
	$healthbar.visible = health < max_health
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
