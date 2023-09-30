extends CanvasLayer
@export var player: CharacterBody2D

func _process(delta):
	$healthbar.value = player.health
	$staminabar.value = player.stamina
	if player.is_exhauted:
		$exhauted.text = "Exhauted!"
	else:
		$exhauted.text = ""
