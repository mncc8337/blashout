extends CharacterBody2D

signal being_attacked(damage)

@export var SPEED = 600.0
@export var max_health:float = 100
var health = 100.0
@export var attack_dmg = 10
@export var attack_range = 50 # in px
@export var attack_cooldown = 1.5
@onready var player = get_tree().get_root().get_node("main/player")
var die = false

var sqr_attack_range

func _ready():
	$AnimationPlayer.play("spawn")
	
	health = max_health
	$healthbar.max_value = max_health
	
	$attack_cooldown.wait_time = abs(attack_cooldown)
	sqr_attack_range = attack_range * attack_range
	
	being_attacked.connect(receive_damage)
	
	$die_timer.timeout.connect(queue_free)

func receive_damage(damage):
	if die:
		return

	if is_in_group("foe"):
		health -= damage
	else:
		health -= 0.1
	if health <= 0:
		die = true
		if is_in_group("foe"):
			#do sth before this
			var main = get_tree().get_root().get_node("main")
			var rnd = main.rng.randi_range(1, 100)
			if rnd < 25:
				var grave = main.grave_model.instantiate()
				grave.position = position
				main.get_node("graves").add_child(grave)
			main.foe_killed += 1
			main.foe_killed_total += 1
			SPEED = 0
			attack_dmg = 0
		$die_timer.start()
		$AnimationPlayer.play("die")
		return

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
