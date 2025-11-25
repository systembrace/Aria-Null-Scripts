extends Node2D
class_name PlayerControl

@export var body: CharacterBody2D
@export var dash: Dash
@export var combo: Combo
@export var hitstun: Hitstun
@export var health: Health
@export var parry_checker: ParryChecker
@export var can_heal=true
@export var has_speed_boost=false

var min_speed
var max_speed
var accel
var speed_falloff_time
var dir=Vector2.ZERO
var speed
var speed_falloff=0
var attackpush=0
var stunned=false
var input_buffer
var dead=false
var inventory: Inventory
var healing=false
var paused=false
@onready var healtimer=$HealTimer

func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	max_speed=body.max_speed
	min_speed=body.min_speed
	accel=body.accel
	speed=float(max_speed)
	if has_speed_boost:
		speed=float(min_speed)
		speed_falloff_time=body.speed_falloff_time
		speed_falloff=-speed_falloff_time/2
	if hitstun:
		hitstun.stunned.connect(stun)
		hitstun.recover.connect(recover)
	if health:
		health.took_damage.connect(damaged)
		health.dead.connect(death_throes)
	if combo:
		combo.parry.connect(speed_boost)
	healtimer.wait_time=1
	healtimer.timeout.connect(stop_heal)

func death_throes():
	dead=true
	if hitstun:
		hitstun.stun()

func die():
	var main=get_tree().get_root().get_node("Main")
	var die_sfx=$Die.duplicate()
	main.add_child(die_sfx)
	die_sfx.play()
	die_sfx.global_position=global_position
	if !main:
		return
	if body.original_player:
		var playercorpse=load("res://Scenes/Allies/player_corpse.tscn").instantiate()
		playercorpse.global_position=body.global_position
		main.add_child(playercorpse)
	else:
		body.create_tessa()
	if body.original_player or main.player_corpse:
		var playerghost=load("res://Scenes/Allies/player_ghost.tscn").instantiate()
		playerghost.tessa=body.tessa
		if body.original_player:
			playerghost.global_position=body.global_position
		else:
			playerghost.global_position=main.player_corpse.global_position
		playerghost.inventory=inventory
		playerghost.maxhp=health.maxhp
		playerghost.firstdeath=inventory.can_revive
		#inventory.can_revive=false
		main.add_child(playerghost)
	elif !body.original_player and !main.player_corpse:
		undo_dummy()
		main.player.hurtbox.take_non_attack_damage("HoloDied")
	body.queue_free()
	#inventory.call_deferred("set","can_revive",false)
	if inventory.can_revive and body.original_player:
		Global.slow_down_to_zero=true

func undo_dummy():
	var main=get_tree().get_root().get_node("Main")
	inventory.dummy.create_player(body.tessa)
	inventory.dummy=null
	body.queue_free()
	$DeHologram.play()
	$DeHologram.reparent(main)

func speed_boost(bypass=false):
	if bypass or speed>max_speed:
		speed=min(speed+accel,max_speed+accel)
	else:
		speed=min(speed+accel,max_speed)
	reset_speed_falloff()

func collect_scrap():
	$Collect.play()
	inventory.scrap+=1

func rally():
	health.rally()
	if is_instance_valid(inventory):
		inventory.gain_ammo()

func stop_heal():
	inventory.heals-=1
	inventory.ammo=60
	healing=false
	health.heal()

func damaged():
	Global.hitstop(.3,true)
	speed_falloff=0
	input_buffer=null
	if healing:
		healing=false
		healtimer.stop()
		$Heal.stop()

func stun():
	stunned=true
	
func recover():
	stunned=false
	if dead:
		die()

func reset_speed_falloff():
	if has_speed_boost:
		if speed>max_speed:
			speed_falloff=speed_falloff_time/2
		elif speed>min_speed:
			speed_falloff=speed_falloff_time

func pause():
	paused=true
	combo.disable_hitbox()
	dir=Vector2.ZERO
	body.velocity=dir

func prevent_attack():
	combo.enable_attack()

func prevent_movement():
	dir=Vector2.ZERO
	body.velocity=body.velocity.move_toward(Vector2.ZERO,accel/2)

func _process(delta):
	if paused:
		prevent_movement()
		#prevent_attack()
		return
	if stunned:
		prevent_movement()
		prevent_attack()
		if not dead and Input.is_action_just_pressed("attack"):
			parry_checker.try_parry()
		return
	
	dir=Input.get_vector("left","right","up","down")
	
	if inventory:
		if can_heal and Input.is_action_just_released("heal") and (health.hp<health.maxhp or inventory.ammo<60) and not healing and inventory.heals>0:
			healing=true
			healtimer.start()
			$Heal.play()
			body.healing.emit()
		
		if healing:
			prevent_movement()
			prevent_attack()
			return
		
		#if Input.is_action_pressed("use item") and inventory.item and inventory.item.num>0:
		#	prevent_movement()
		#	return
		
		if ((not combo.is_charging() and not Input.is_action_pressed("attack") and (!dash or not dash.dashing)) or (inventory.secondary is Grapple and inventory.secondary.harpoon and inventory.secondary.harpoon.stuck_in_enemy)) and (((inventory.secondary is Gun or inventory.secondary is Shield) and not inventory.secondary is Grapple and Input.is_action_pressed("secondary")) or ((not inventory.secondary is Gun or inventory.secondary is Grapple) and Input.is_action_just_released("secondary"))) and (!inventory.secondary is Shield or combo.can_attack()):
			inventory.use_secondary()
		
		if (inventory.secondary is Gun or inventory.secondary is Shield) and inventory.secondary.cant_move and not combo.is_attacking():
			prevent_movement()
		
		if not combo.is_charging() and (!dash or not dash.dashing) and Input.is_action_just_released("hologram"):
			if body.original_player and inventory.revival!="none":
				inventory.revive()
				body.create_dummy()
				body.queue_free()
			elif !body.original_player and inventory.dummy:
				body.create_tessa(false)
				undo_dummy()
	
	if Input.is_action_just_pressed("attack") or input_buffer=="attack":
		if not combo.is_done_attacking():
			input_buffer="attack"
		else:
			combo.attack()
			if input_buffer=="attack" and combo.is_charging() and not Input.is_action_pressed("attack"):
				combo.release()
			input_buffer=null
	if combo.is_charging():
		dir/=2
		if Input.is_action_just_released("attack"):
			combo.release()
	
	if has_speed_boost:
		if speed_falloff>0:
			speed_falloff=max(0,speed_falloff-delta)
		if speed_falloff==0:
			if speed>max_speed:
				speed=max_speed
				reset_speed_falloff()
			elif speed>min_speed:
				speed=min_speed
				reset_speed_falloff()
	
	if Input.is_action_just_pressed("dash") or input_buffer=="dash":
		if body.on_floor and dash and not dash.dashing and not stunned and combo.is_done_attacking():
			dash.start_dash()
			if inventory.secondary is Shield:
				inventory.secondary.deactivate()
			input_buffer=null
		else:
			input_buffer="dash"
	if combo.is_damaging() and combo.attack_push().length()>0 and attackpush==0:
		attackpush=1
	if attackpush==1:
		var boost=0
		if has_speed_boost:
			boost=float(speed-min_speed)/(max_speed-min_speed)*30
		body.velocity=combo.attack_push(boost)
		attackpush=2
	elif not combo.is_damaging():
		attackpush=0
	if combo.can_move() and not body.aiming:
		var boost_accel=accel*60*delta
		if has_speed_boost and dir!=Vector2.ZERO:
			boost_accel=accel+(speed-min_speed)/(max_speed-min_speed)*8
		body.velocity=body.velocity.move_toward(dir*speed,boost_accel)
	else:
		body.velocity=body.velocity.move_toward(Vector2.ZERO,accel*30*delta)
		if inventory.secondary is Shield:
			inventory.secondary.deactivate()
