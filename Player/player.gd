extends CharacterBody2D


var speed = 40.0
var hp = 80.0

#Attacks
var blueFlame = preload("res://Player/Attack/blue_flame.tscn")

#Attack nodes
@onready var blueFlameTimer = get_node("%BlueFlameTimer")
@onready var blueFlameAttackTimer = get_node("%BlueFlameAttackTimer")

#BlueFlame
var blueflame_ammo = 0
var blueflame_baseammo = 1
var blueflame_attackspeed = 1.5
var blueflame_level = 1

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
