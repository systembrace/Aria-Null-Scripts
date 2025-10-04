extends Entity
class_name Player

@export var target: Node2D
@export var min_speed=96
@export var max_speed=160
@export var accel=16
@export var speed_falloff_time=10
@export var secondary:Node2D
@export var original_player=true
signal collision
var speed=min_speed
var inventory: Inventory
var dir=Vector2.DOWN
var veldir=Vector2.DOWN
var aiming=false
signal healing
@onready var control=$Control

func _ready():
	super._ready()
	if original_player:
		make_scarf()
		fell.connect(make_scarf)
	else:
		$Hurtbox.disable_hurtbox()
		$Hurtbox.timer.start()

func make_scarf():
	if !original_player:
		return
	var main=get_tree().get_root().get_node("Main")
	var scarf=Node2D.new()
	scarf.set_script(ScarfStart)
	scarf.parent=self
	scarf.global_position=round(global_position+Vector2.UP)
	main.call_deferred("add_child",scarf)

func _process(_delta):
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

func _physics_process(delta):
	super._physics_process(delta)
	var coll = move_and_collide(velocity*delta,true)
	if coll:
		collision.emit(coll)
	move_and_slide()

func save_data():
	var data = {
		"name":"Player",
		"path":scene_file_path,
		"pos_x":prev_location.x,
		"pos_y":prev_location.y,
		"health":$Health.hp,
		"prevhp":$Health.prevhp,
		"dir":var_to_str($AnimationController.direction),
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
