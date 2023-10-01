extends StaticBody2D

var health

#func _physics_process(delta):
#	$LightOccluder2D1.scale.x = sign($"../player".position.x - position.x)
#	$LightOccluder2D2.scale.y = sign($"../player".position.y - position.y)
#	if $LightOccluder2D2.scale.y < 0:
#		$LightOccluder2D2.scale.x = 1.335
#	else:
#		$LightOccluder2D2.scale.x = 1
