extends CharacterBody2D


var speed = 40.0
var hp = 80.0
var last_movement = Vector2.UP

#Attacks
var blueFlame = preload("res://Player/Attack/blue_flame.tscn")
var storm = preload("res://Player/Attack/storm.tscn")
var orange_flame = preload("res://Player/Attack/orange_flame.tscn")

#Attack nodes
@onready var blueFlameTimer = get_node("%BlueFlameTimer")
@onready var blueFlameAttackTimer = get_node("%BlueFlameAttackTimer")
@onready var stormTimer = get_node("%StormTimer")
@onready var stormAttackTimer = get_node("%StormAttackTimer")
@onready var orangeFlameBase = get_node("%OrangeFlameBase")

#BlueFlame
var blueflame_ammo = 0
var blueflame_baseammo = 1
var blueflame_attackspeed = 1.5
var blueflame_level = 0

#Storm
var storm_ammo = 0
var storm_baseammo = 1
var storm_attackspeed = 3
var storm_level = 0

#OrangeFlame
var orangeflame_ammo = 1
var orangeflame_level = 1

#Enemy Related
var enemy_close = []

var player_state

func _ready():
	attack()

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0 or direction.y != 0:
		player_state = "walking"
	last_movement = direction
	velocity = direction * speed
	move_and_slide()
	
	play_anim(direction)
	
func play_anim(dir):
	if player_state == "idle":
		$AnimatedSprite2D.play("idle")
	if player_state == "walking":
		if dir.y == -1:
			$AnimatedSprite2D.play("move_up")
		if dir.x == 1:
			$AnimatedSprite2D.play("move_right")
		if dir.y == 1:
			$AnimatedSprite2D.play("move_down")
		if dir.x == -1:
			$AnimatedSprite2D.play("move_left")

func attack():
	if blueflame_level > 0:
		blueFlameTimer.wait_time = blueflame_attackspeed
		if blueFlameTimer.is_stopped():
			blueFlameTimer.start()
	if storm_level > 0:
		stormTimer.wait_time = storm_attackspeed
		if stormTimer.is_stopped():
			stormTimer.start()
	if orangeflame_level > 0:
		spawn_orange_flame()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)


func _on_blue_flame_timer_timeout():
	blueflame_ammo += blueflame_baseammo
	blueFlameAttackTimer.start()


func _on_blue_flame_attack_timer_timeout():
	if blueflame_ammo > 0:
		var blueflame_attack = blueFlame.instantiate()
		blueflame_attack.position = position
		blueflame_attack.target = get_random_target()
		blueflame_attack.level = blueflame_level
		add_child(blueflame_attack)
		blueflame_ammo -= 1
		if blueflame_ammo > 0:
			blueFlameAttackTimer.start()
		else:
			blueFlameAttackTimer.stop()
			
func _on_storm_timer_timeout():
	storm_ammo += storm_baseammo
	stormAttackTimer.start()


func _on_storm_attack_timer_timeout():
	if storm_ammo > 0:
		var storm_attack = storm.instantiate()
		storm_attack.position = position
		storm_attack.last_movement = last_movement
		storm_attack.level = storm_level
		add_child(storm_attack)
		storm_ammo -= 1
		if storm_ammo > 0:
			stormAttackTimer.start()
		else:
			stormAttackTimer.stop()

func spawn_orange_flame():
	var get_orangeflame_total = orangeFlameBase.get_child_count()
	var calc_spawns = orangeflame_ammo - get_orangeflame_total
	while calc_spawns > 0 :
		var orangeflame_spawn = orange_flame.instantiate()
		orangeflame_spawn.global_position = global_position
		orangeFlameBase.add_child(orangeflame_spawn)
		calc_spawns -= 1

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
