extends Node2D
class_name Item

@export var type="grenades"
@export var num:int=0
@export var max_amt=0
@export var limit=30
@export var buffer=.5
@export var chargetime=-1
var player: Player
var main
@onready var timer=$Timer

var use_funcs={"grenades":use_grenade,"earthshaker":use_earthshaker}

func _ready():
	main=get_tree().get_root().get_node("Main")
	timer.wait_time=buffer
	timer.timeout.connect($Ready.play)

func set_buffer():
	timer.wait_time=buffer

func equip(node):
	player=node

func use(charge):
	if timer.is_stopped() and num>0:
		timer.start()
		num-=1
		use_funcs[type].call(charge)

func use_grenade(charge):
	var grenade=load("res://Scenes/Items/grenade.tscn").instantiate()
	if charge>=chargetime:
		grenade.tossed=false
	grenade.global_position=global_position-Vector2.UP*16
	grenade.target=get_global_mouse_position()
	main.call_deferred("add_child",grenade)

func use_earthshaker(charge):
	var dup=1
	if charge>=chargetime:
		dup=8
	for i in range(0,dup):
		var earthshaker=load("res://Scenes/Items/earthshaker.tscn").instantiate()
		earthshaker.global_position=global_position-Vector2.UP*16
		earthshaker.dir=earthshaker.to_local(get_global_mouse_position()).normalized()
		earthshaker.velocity=player.velocity
		if i>0:
			earthshaker.dir=earthshaker.dir.rotated(i*2*PI/dup)
			earthshaker.charged=true
		main.call_deferred("add_child",earthshaker)
