extends CharacterBody2D
@onready var player = get_tree().get_root().get_node("main/player")
@export var block_moving_delay = 2
@onready var block_model = preload("res://scenes/blck.tscn")
var rng = RandomNumberGenerator.new()
var i=0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
func _physics_process(delta):
	#if player.position.x
	#$block_moving_timer.wait_time = block_moving_delay
	if $block_moving_timer.is_stopped():
		self.position.x+=rng.randi_range(-1,1)*34
		self.position.y+=rng.randi_range(-1,1)*34
		move_and_slide()
		$block_moving_timer.start()

		

