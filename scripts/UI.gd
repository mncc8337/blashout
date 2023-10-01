extends CanvasLayer
@export var player: CharacterBody2D

func _process(delta):
	$healthbar.max_value = player.max_health
	$healthbar.value = player.health
	$staminabar.value = player.stamina
	if player.is_exhausted:
		$exhausted.text = "Exhausted!"
	else:
		$exhausted.text = ""
