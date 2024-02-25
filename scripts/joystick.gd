extends TouchScreenButton

@onready var housing_radius = shape.radius
@onready var numb_radius = $numb.scale.x * housing_radius

signal joystick_moved

var current_index = -1

var direction = Vector2(0, 1)

func _unhandled_input(event):
	if event is InputEventScreenTouch and self.is_pressed():
		current_index = event.index
	if event is InputEventScreenDrag and current_index == event.index:
		direction = (event.position - self.global_position).limit_length(housing_radius - numb_radius)
		
		$numb.global_position = self.global_position + direction
		direction /= housing_radius - numb_radius
		joystick_moved.emit(direction)

func _on_released():
	current_index = -1
	$numb.position = Vector2.ZERO