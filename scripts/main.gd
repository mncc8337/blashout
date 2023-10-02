extends Node2D

signal died

var rng = RandomNumberGenerator.new()

@onready var foe_model = preload("res://scenes/foe.tscn")
@onready var grave_model = preload("res://scenes/grave.tscn")
var foe_attack_dmg_max:float = 10
var foe_speed_max:float = 1300.0
var foe_health_max:float = 100
var foe_attack_cooldown_max:float = 1.5

@export var demo_scene:bool = false

@export var foe_spawn_delay:float = 1.5
var foe_spawned:int = 0
var foe_killed:int = 0
var foe_killed_total:int = 0
var current_foe_count_max:int = 20
var wave_count:int = 1

enum FOE_CLASS {RANDOM, BIGASS, ROACH}
enum SKILL {CAT_EYES, STRONGER_LIGHT, LARGER_LIGHT, RUNNER, MEDIC, RECKLESS, TOMB_RAIDER, EARTH_QUAKE, WITCH}

var skilllist = [0, 1, 2, 3, 4, 5, 6, 7, 8]
var skill_goal:int = 10

var panel1_label
var panel1_desc
var panel2_label
var panel2_desc
var panel3_label
var panel3_desc

func fetch_skill(skill):
	var info = ["skill name", "skill description"]
	if skill == SKILL.CAT_EYES:
		info[0] = "cat eyes"
		info[1] = "increase your base vision by 10%"
	elif skill == SKILL.STRONGER_LIGHT:
		info[0] = "stronger light"
		info[1] = "increase your damage to ghost by 5%"
	elif skill == SKILL.LARGER_LIGHT:
		info[0] = "larger light"
		info[1] = "make your light reach 7% further"
	elif skill == SKILL.RUNNER:
		info[0] = "runner"
		info[1] = "increase your stamina and your base speed by 5%"
	elif skill == SKILL.MEDIC:
		info[0] = "medic"
		info[1] = "heal yourself 5% faster"
	elif skill == SKILL.RECKLESS:
		info[0] = "reckless"
		info[1] = "allow you to redirect your light to any directions while running"
	elif skill == SKILL.TOMB_RAIDER:
		info[0] = "tomb raider"
		info[1] = "remove graves by pointing light at it (it takes time)"
	elif skill == SKILL.EARTH_QUAKE:
		info[0] = "earth quake"
		info[1] = "reduce the number of grave by 25%"
	elif skill == SKILL.WITCH:
		info[0] = "witch"
		info[1] = "instantly heal 25% of your health"

	return info

func apply_skill(skill):
	if skill == SKILL.CAT_EYES:
		$player.get_node("vision").texture_scale *= 1.1
		if $player.get_node("vision").texture_scale >= 15:
			$player.get_node("vision").texture_scale = 15
			skilllist.erase(SKILL.CAT_EYES)
	elif skill == SKILL.STRONGER_LIGHT:
		$player.max_attack_dmg *= 1.05
	elif skill == SKILL.LARGER_LIGHT:
		$player.get_node("flashlight").scale.x *= 1.07
		if $player.get_node("flashlight").scale.x >= 0.5:
			$player.get_node("flashlight").scale.x = 0.5
			skilllist.erase(SKILL.LARGER_LIGHT)
	elif skill == SKILL.RUNNER:
		$player.max_stamina *= 1.07
		$player.SPEED *= 1.07
	elif skill == SKILL.MEDIC:
		$player.get_node("healing_timer").wait_time *= 0.95
		if $player.get_node("healing_timer").wait_time < 10:
			$player.get_node("healing_timer").wait_time = 10
			skilllist.erase(SKILL.MEDIC)
	elif skill == SKILL.RECKLESS:
		$player.furious = true
		skilllist.erase(SKILL.RECKLESS)
	elif skill == SKILL.TOMB_RAIDER:
		$player.tomb_raider = true
		skilllist.erase(SKILL.TOMB_RAIDER)
	elif skill == SKILL.EARTH_QUAKE:
		var all_grave = $graves.get_children()
		all_grave.shuffle()
		var num = ceil(all_grave.size()/4.0)
		for i in num:
			all_grave[i].die_proc()
	elif skill == SKILL.WITCH:
		$player.health = clamp($player.health + 0.25 * $player.max_health, 0, $player.max_health)

func choose_skill(x):
	apply_skill(skilllist[x])
	$skill_panel.visible = false
	get_tree().paused = false

func choose_skill1(): choose_skill(0)
func choose_skill2(): choose_skill(1)
func choose_skill3(): choose_skill(2)

func pause_game():
	$pause_menu.visible = true
	get_tree().paused = true

func unpause_game():
	$pause_menu.visible = false
	get_tree().paused = false

func to_main_menu():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

func _ready():
	$foe_spawn_timer.wait_time = foe_spawn_delay
	$foe_spawn_timer.timeout.connect(spawn_foe)

	if !demo_scene:
		$UI/pause.button_down.connect(pause_game)
		$pause_menu/VBoxContainer/Button.button_down.connect(unpause_game)
		$pause_menu/VBoxContainer/Button2.button_down.connect(to_main_menu)
		
		died.connect(show_death_screen)
		$death_UI/Button.button_down.connect(replay)
		
		$wave_start_timer.timeout.connect(start_wave)
		
		panel1_label = $skill_panel/HBoxContainer/Panel/VBoxContainer/Label
		panel1_desc = $skill_panel/HBoxContainer/Panel/VBoxContainer/Label2
		$skill_panel/HBoxContainer/Panel/VBoxContainer/Button.button_down.connect(choose_skill1)

		panel2_label = $skill_panel/HBoxContainer/Panel2/VBoxContainer/Label
		panel2_desc = $skill_panel/HBoxContainer/Panel2/VBoxContainer/Label2
		$skill_panel/HBoxContainer/Panel2/VBoxContainer/Button.button_down.connect(choose_skill2)

		panel3_label = $skill_panel/HBoxContainer/Panel3/VBoxContainer/Label
		panel3_desc = $skill_panel/HBoxContainer/Panel3/VBoxContainer/Label2
		$skill_panel/HBoxContainer/Panel3/VBoxContainer/Button.button_down.connect(choose_skill3)
	else:
		$UI.visible = false
		$wave_start_timer.autostart = false
		current_foe_count_max = 100
		foe_attack_dmg_max = 0
		$foe_spawn_timer.wait_time = 0.5
		$foe_spawn_timer.start()

func start_wave():
	$foe_spawn_timer.start()

func increase_diff():
	if $foe_spawn_timer.wait_time > 0.2:
		$foe_spawn_timer.wait_time *= 0.95
	else:
		$foe_spawn_timer.wait_time > 0.2
	if foe_attack_dmg_max < 30:
		foe_attack_dmg_max *= 1.05
	else:
		foe_attack_dmg_max = 30
	foe_speed_max *= 1.01
	foe_health_max *= 1.05
	if foe_attack_cooldown_max > 0.5:
		foe_attack_cooldown_max *= 0.98
	else:
		foe_attack_cooldown_max = 0.5
	current_foe_count_max *= 1.2

func spawn_foe():
	if foe_spawned == current_foe_count_max:
		if !demo_scene:
			$foe_spawn_timer.stop()
		return
	
	var foe_instance = foe_model.instantiate()
	var angle = rng.randf_range(-PI, PI)
	var rand_dir = Vector2(cos(angle), sin(angle))
	var dir = rand_dir * 300 + $player.position
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
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.9, 2.0)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(0.5, 0.7)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.9, 1.7)
		foe_instance.attack_cooldown = foe_attack_cooldown_max * rng.randf_range(0.7, 1)
	elif foe_class == FOE_CLASS.ROACH:
		foe_instance.attack_dmg = foe_attack_dmg_max * rng.randf_range(0.3, 0.5)
		foe_instance.SPEED = foe_speed_max * rng.randf_range(2, 4)
		foe_instance.max_health = foe_health_max * rng.randf_range(0.3, 0.5)
		foe_instance.attack_cooldown = foe_attack_cooldown_max * rng.randf_range(0.5, 0.7)
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
	if Input.is_action_just_pressed("pause_game") and !demo_scene:
		pause_game()
	
	$UI/VBoxContainer.size.x = get_viewport().get_size().x * 0.15
	$UI/VBoxContainer/healthbar.max_value = ceil($player.max_health)
	$UI/VBoxContainer/healthbar.value = ceil($player.health)
	$UI/VBoxContainer/staminabar.max_value = ceil($player.max_stamina)
	$UI/VBoxContainer/staminabar.value = $player.stamina

	if $player.is_exhausted:
		$UI/VBoxContainer/exhausted.text = "Exhausted!"
	else:
		$UI/VBoxContainer/exhausted.text = ""
	
	if demo_scene:
		if foe_killed > 0:
			foe_killed = 0
			current_foe_count_max += 1
		return
	
	if !$wave_start_timer.is_stopped():
		$UI/info.text = "wave %d start in %d" % [wave_count, $wave_start_timer.time_left]
	else:
		$UI/info.text = str(current_foe_count_max - foe_killed) + '/' + str(current_foe_count_max) + " foe(s) remain"

	if foe_killed == current_foe_count_max:
		new_wave()
	
	if foe_killed_total == skill_goal:
		skill_goal += 20
		get_tree().paused = true
		
		skilllist.shuffle()
		
		var s1info = fetch_skill(skilllist[0])
		var s2info = fetch_skill(skilllist[1])
		var s3info = fetch_skill(skilllist[2])
		
		panel1_label.text = s1info[0]
		panel1_desc.text = s1info[1]
		
		panel2_label.text = s2info[0]
		panel2_desc.text = s2info[1]
		
		panel3_label.text = s3info[0]
		panel3_desc.text = s3info[1]
		$skill_panel.visible = true
