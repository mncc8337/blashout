extends Area2D
@onready var player = get_tree().get_root().get_node("main/player")
@export var block_moving_delay = 1
var rng = RandomNumberGenerator.new()
var new_pos

func _ready():
	new_pos = position

func _physics_process(delta):
	$block_moving_timer.wait_time = block_moving_delay
	if $block_moving_timer.is_stopped():
		new_pos = position
		var rand = rng.randf_range(-PI, PI)
		new_pos += Vector2(cos(rand), sin(rand)) * 34
		if (new_pos.x>1250 and new_pos.y>650) or (new_pos <= Vector2.ZERO):
			new_pos=Vector2(rng.randi_range(150,550),rng.randi_range(50,250))
		$block_moving_timer.start()
	
	position = lerp(position, new_pos, 0.01)
