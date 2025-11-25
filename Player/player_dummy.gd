extends Entity
class_name PlayerDummy

var main: Main
var start_hp=5
var start_prevhp=5
var max_hp=5
var accel=16
var min_speed=52
var max_speed=104
var loaded_in=false
@onready var health=$Health
@onready var hp_bar=$HPBar

func _ready():
	super._ready()
	main=get_tree().get_root().get_node("Main")
	if loaded_in:
		main.inventory.dummy=self
	health.set_max(max_hp)
	health.set_hp(start_hp)
	health.prevhp=start_prevhp
	health.dead.connect(death_throes)

	hp_bar.position.x=int(-13*max_hp/2.0)-1
	hp_bar.health=health
	hp_bar.hpcountupdated(max_hp)
	health.hpchanged.connect(hp_bar.show)
	health.hpchanged.connect(hp_bar.updatepip)
	hurtbox.hurtboxenabled.connect(hp_bar.hide)

func create_player(tessa):
	if !main:
		return
	var scene=load("res://Scenes/Allies/player.tscn")
	var player: Node2D =scene.instantiate()
	var data={
		"name":"Player",
		"path":"res://Scenes/Allies/player.tscn",
		"pos_x":global_position.x,
		"pos_y":global_position.y,
		"health":health.hp,
		"prevhp":health.prevhp,
		"dir":var_to_str(find_child("AnimationController").direction),
	}
	player.load_data(data)
	player.tessa=tessa
	main.add_child(player)
	main.player=player
	queue_free()

func death_throes():
	hurtbox.hurtboxenabled.connect(die)

func die():
	var playercorpse=load("res://Scenes/Allies/player_corpse.tscn").instantiate()
	playercorpse.global_position=global_position
	main.add_child(playercorpse)
	if !main.inventory.can_revive:
		main.player.control.die()
	main.inventory.dummy=null
	queue_free()

func _physics_process(delta):
	velocity=velocity.move_toward(Vector2.ZERO,accel/2)
	super._physics_process(delta)
	move_and_slide()

func save_data():
	var data = {
		"name":"PlayerDummy",
		"path":scene_file_path,
		"pos_x":prev_location.x,
		"pos_y":prev_location.y,
		"health":$Health.hp,
		"prevhp":$Health.prevhp,
		"dir":var_to_str(find_child("AnimationController").direction),
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
		$AnimationController.direction=str_to_var(data["dir"])
	loaded_in=true
