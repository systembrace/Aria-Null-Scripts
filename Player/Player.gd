extends Entity
class_name Player

@export var target: Node2D
@export var min_speed=96
@export var max_speed=160
@export var accel=16
@export var speed_falloff_time=10
@export var secondary:Node2D
@export var original_player=true
@export var virtual=false
@export var mask: Sprite2D
@export var anim_controller:AnimationController
signal collision
var speed=min_speed
var inventory: Inventory
var dir=Vector2.DOWN
var veldir=Vector2.DOWN
var aiming=false
var main: Main
var scarf
var tessa
var has_tessa=true
var revive=false
signal healing
@onready var control:PlayerControl=$Control

func _ready():
	super._ready()
	main=get_tree().get_root().get_node("Main")
	if virtual:
		return
	if original_player:
		make_scarf()
		fell.connect(make_scarf)
		if has_tessa and !revive and !tessa:
			call_deferred("create_tessa")
		if revive:
			$Revive.play()
			get_tree().create_timer(.75,false).timeout.connect(stop_revive)
			control.pause()
	else:
		$Hurtbox.disable_hurtbox()
		$Hurtbox.timer.start()
		$Hologram.play()

func make_scarf():
	if !original_player:
		return
	scarf=Node2D.new()
	scarf.set_script(ScarfStart)
	scarf.parent=self
	scarf.global_position=round(global_position+Vector2.UP)
	main.call_deferred("add_child",scarf)

func create_tessa(rand_position=true):
	tessa=load("res://Scenes/Allies/Tessa.tscn").instantiate()
	var positions=[Vector2.ZERO]
	if rand_position:
		positions.clear()
		var ray=RayCast2D.new()
		add_child(ray)
		ray.set_collision_mask_value(1,false)
		ray.set_collision_mask_value(10,true)
		ray.set_collision_mask_value(18,true)
		ray.position=Vector2.ZERO
		for i in range(0,8):
			ray.target_position=Vector2(24,0).rotated(PI/4*i)
			ray.force_raycast_update()
			if !ray.is_colliding():
				positions.append(ray.target_position)
	main.call_deferred("add_child",tessa)
	if len(positions)==0:
		positions.append(Vector2.ZERO)
	tessa.global_position=global_position+positions.pick_random().normalized()*16
	tessa.prev_location=global_position

func stop_revive():
	revive=false
	control.paused=false

func create_dummy():
	if !main:
		return
	var player_dummy:PlayerDummy=load("res://Scenes/Allies/player_dummy.tscn").instantiate()
	player_dummy.find_child("AnimationController").direction=find_child("AnimationController").direction
	player_dummy.start_hp=control.health.hp
	player_dummy.start_prevhp=control.health.prevhp
	player_dummy.max_hp=control.health.maxhp
	main.add_child(player_dummy)
	player_dummy.global_position=global_position
	inventory.dummy=player_dummy

func _process(delta):
	if name!="Player":
		name="Player"
	
	aiming=Input.is_action_pressed("aim")
	var inputdir=Input.get_vector("left","right","up","down")
	var newdir=velocity
	if newdir.length()>accel*2:
		veldir=newdir.normalized()
	if inputdir.length()!=0:
		dir=inputdir
	elif not aiming:
		dir=veldir
	
	if !original_player and mask.offset.y!=-32:
		mask.offset.y=move_toward(mask.offset.y,-32,64*delta)
		if mask.offset.y==-32:
			control.paused=false
	
	if !Global.endless and !original_player and inventory.can_revive and main.player_corpse and main.num_enemies()==0:
		create_tessa(false)
		main.player_corpse.revive(tessa)
		name="GONE"
		inventory.can_revive=false
		free()

func _physics_process(delta):
	super._physics_process(delta)
	if main.num_enemies(true)>0 and !get_collision_mask_value(23):
		set_collision_mask_value(23,true)
	elif (!Global.endless or !main.inventory.dummy) and main.num_enemies(true)==0 and get_collision_mask_value(23):
		set_collision_mask_value(23,false)
	var coll = move_and_collide(velocity*delta,true)
	if coll:
		collision.emit(coll)
	move_and_slide()

func save_data():
	var path=scene_file_path
	var hp=$Health.hp
	var prevhp=$Health.prevhp
	if Global.endless and inventory and is_instance_valid(inventory.dummy):
		path="res://Scenes/Allies/player.tscn"
		hp=inventory.dummy.health.hp
		prevhp=inventory.dummy.health.prevhp
	var data = {
		"name":"Player",
		"path":path,
		"pos_x":prev_location.x,
		"pos_y":prev_location.y,
		"health":hp,
		"prevhp":prevhp,
		"dir":var_to_str(anim_controller.direction),
	}
	return data

func load_data(data):
	add_to_group("to_save")
	name=data["name"]
	global_position.x=data["pos_x"]
	global_position.y=data["pos_y"]
	prev_location=global_position
	$Health.hp=min($Health.maxhp,data["health"])
	if "prevhp" in data.keys():
		$Health.prevhp=min($Health.maxhp,data["prevhp"])
	else:
		$Health.prevhp=$Health.hp
	if "dir" in data.keys():
		anim_controller.direction=str_to_var(data["dir"])
