extends Node2D

signal died

var rng = RandomNumberGenerator.new()

@onready var foe_model = preload("res://scenes/foe.tscn")
@onready var grave_model = preload("res://scenes/grave.tscn")
var foe_attack_dmg_max:float = 10
var foe_speed_max:float = 900.0
var foe_health_max:float = 100
var foe_attack_cooldown_max:float = 1.5

@export var foe_spawn_delay:float = 1
var foe_spawned:int = 0
var foe_killed:int = 0
var foe_killed_total:int = 0
var current_foe_count_max:int = 20
var wave_count:int = 1

enum FOE_CLASS {RANDOM, BIGASS, ROACH}
enum SKILL {CAT_VISION, STRONGER_LIGHT, LARGER_LIGHT, RUNNER, MEDIC, FURIOUS, TOMB_RAIDER}

var skilllist = [0, 1, 2, 3, 4, 5, 6]

var panel1_label
var panel1_img
var panel1_desc
var panel2_label
var panel2_img
var panel2_desc
var panel3_label
var panel3_img
var panel3_desc

func fetch_skill(skill):
	var info = ["skill name", "skill image path", "skill description"]
	if skill == SKILL.CAT_VISION:
		info[0] = "cat vision"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "increase your base vision by 5%"
	elif skill == SKILL.STRONGER_LIGHT:
		info[0] = "stronger light"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "increase your damage to ghost by 10%"
	elif skill == SKILL.LARGER_LIGHT:
		info[0] = "larger light"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "make your light reach 5% further"
	elif skill == SKILL.RUNNER:
		info[0] = "runner"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "increase your stamina by 7%"
	elif skill == SKILL.MEDIC:
		info[0] = "medic"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "heal yourself 5% faster"
	elif skill == SKILL.FURIOUS:
		info[0] = "furious"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "allow you to redirect your light to any directions while running"
	elif skill == SKILL.TOMB_RAIDER:
		info[0] = "tomb raider"
		info[1] = "res://imgs/skillimg.png"
		info[2] = "remove grave by point light at it (it takes time)"

	return info

func apply_skill(skill):
	if skill == SKILL.CAT_VISION:
		$player.get_node("vision").texture_scale *= 1.05
		if $player.get_node("vision").texture_scale >= 15:
			$player.get_node("vision").texture_scale = 15
			skilllist.erase(SKILL.CAT_VISION)
	elif skill == SKILL.STRONGER_LIGHT:
		$player.max_attack_dmg *= 1.1
	elif skill == SKILL.LARGER_LIGHT:
		$player.get_node("flashlight").scale.x *= 1.05
		if $player.get_node("flashlight").scale.x >= 0.5:
			$player.get_node("flashlight").scale.x = 0.5
			skilllist.erase(SKILL.LARGER_LIGHT)
	elif skill == SKILL.RUNNER:
		$player.max_stamina *= 1.07
	elif skill == SKILL.MEDIC:
		$player.get_node("healing_timer").wait_time *= 1.05
	elif skill == SKILL.FURIOUS:
		$player.furious = true
		skilllist.erassddwe(SKILL.FURIOUS)
	elif skill == SKILL.TOMB_RAIDER:
		$player.tomb_raider = true
		skilllist.erase(SKILL.TOMB_RAIDER)

func choose_skill(x):
	apply_skill(skilllist[x])
	$skill_panel.visible = false
	get_tree().paused = false
	new_wave()

func choose_skill1(): choose_skill(0)
func choose_skill2(): choose_skill(1)
func choose_skill3(): choose_skill(2)

func _ready():
	died.connect(show_death_screen)
	$death_UI/Button.button_down.connect(replay)
	
	$foe_spawn_timer.wait_time = foe_spawn_delay
	$foe_spawn_timer.timeout.connect(spawn_foe)
	
	$wave_start_timer.timeout.connect(start_wave)
	
	panel1_label = $skill_panel/HBoxContainer/Panel/VBoxContainer/Label
	panel1_img = $skill_panel/HBoxContainer/Panel/VBoxContainer/TextureRect
	panel1_desc = $skill_panel/HBoxContainer/Panel/VBoxContainer/Label2
	$skill_panel/HBoxContainer/Panel/VBoxContainer/Button.button_down.connect(choose_skill1)

	panel2_label = $skill_panel/HBoxContainer/Panel2/VBoxContainer/Label
	panel2_img = $skill_panel/HBoxContainer/Panel2/VBoxContainer/TextureRect
	panel2_desc = $skill_panel/HBoxContainer/Panel2/VBoxContainer/Label2
	$skill_panel/HBoxContainer/Panel2/VBoxContainer/Button.button_down.connect(choose_skill2)

	panel3_label = $skill_panel/HBoxContainer/Panel3/VBoxContainer/Label
	panel3_img = $skill_panel/HBoxContainer/Panel3/VBoxContainer/TextureRect
	panel3_desc = $skill_panel/HBoxContainer/Panel3/VBoxContainer/Label2
	$skill_panel/HBoxContainer/Panel3/VBoxContainer/Button.button_down.connect(choose_skill3)

func start_wave():
	$foe_spawn_timer.start()

func increase_diff():
	$foe_spawn_timer.wait_time *= 0.9
	foe_attack_dmg_max *= 1.1
	foe_speed_max *= 1.05
	foe_health_max *= 1.1
	foe_attack_cooldown_max *= 0.95
	current_foe_count_max *= 1.5

func spawn_foe():
	if foe_spawned == current_foe_count_max:
		$foe_spawn_timer.stop()
		return
	
	var foe_instance = foe_model.instantiate()
	var angle = rng.randf_range(-PI, PI)
	var rand_dir = Vector2(cos(angle), sin(angle))
	var dir = rand_dir * 200 + $player.position
	dir.x = clamp(dir.x, 50, 1300)
	dir.y = clamp(dir.y, 50, 700)
	foe_instance.position = dir

	var foe_class = rng.randi_range(0, 2)
	if foe_class == FOE_CLASS.RANDOM:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.5, 1)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.5, 1)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.5, 1)
		foe_instance.attack_cooldown = foe_attack_cooldown_max * rng.randf_range(0.9, 1.1)
	elif foe_class == FOE_CLASS.BIGASS:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.9, 1.3)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.4, 0.7)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.9, 1.7)
		foe_instance.attack_cooldown = foe_attack_cooldown_max * rng.randf_range(0.3, 0.7)
	elif foe_class == FOE_CLASS.ROACH:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.3, 0.5)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(1.5, 2)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.3, 0.7)
	$foes.add_child(foe_instance)
	
	foe_spawned += 1

func show_death_screen():
	get_tree().paused = true
	$death_UI.visible = true

func replay():
	get_tree().paused = false
	get_tree().reload_current_scene()

func new_wave():
	wave_count += 1
	foe_killed = 0
	foe_spawned = 0
	increase_diff()
	$wave_start_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$UI/healthbar.max_value = ceil($player.max_health)
	$UI/healthbar.value = ceil($player.health)
	$UI/staminabar.max_value = ceil($player.max_stamina)
	$UI/staminabar.value = $player.stamina
	if $player.is_exhausted:
		$UI/exhausted.text = "Exhausted!"
	else:
		$UI/exhausted.text = ""
	
	if !$wave_start_timer.is_stopped():
		$UI/info.text = "wave %d start in %d" % [wave_count, $wave_start_timer.time_left]
	else:
		$UI/info.text = str(current_foe_count_max - foe_killed) + '/' + str(current_foe_count_max) + " remain"

	if foe_killed == current_foe_count_max:
		get_tree().paused = true
		
		skilllist.shuffle()
		
		var s1info = fetch_skill(skilllist[0])
		var s2info = fetch_skill(skilllist[1])
		var s3info = fetch_skill(skilllist[2])
		
		panel1_label.text = s1info[0]
		panel1_img.texture = ImageTexture.create_from_image(Image.load_from_file(s1info[1]))
		panel1_desc.text = s1info[2]
		
		panel2_label.text = s2info[0]
		panel2_img.texture = ImageTexture.create_from_image(Image.load_from_file(s2info[1]))
		panel2_desc.text = s2info[2]
		
		panel3_label.text = s3info[0]
		panel3_img.texture = ImageTexture.create_from_image(Image.load_from_file(s3info[1]))
		panel3_desc.text = s3info[2]
		$skill_panel.visible = true
