extends CharacterBody2D
class_name PlayerGhost

var target
var main
var inventory: Inventory
var tessa
var maxhp=5
var firstdeath=true
var canrevive=false
@onready var timer = $DeathTimer
@onready var revive=$CanvasLayer/ReviveMenu/MarginContainer/VBoxContainer/Revive
@onready var gameover=$CanvasLayer/ReviveMenu/MarginContainer/VBoxContainer/Dead

func _ready():
	main=get_tree().get_root().get_node("Main")
	timer.wait_time=2
	var has_revives=false
	for button in $CanvasLayer/ReviveMenu/MarginContainer/VBoxContainer/Revive/ReviveOptions.get_children():
		button.pressed.connect(revive_as.bind(button.name.to_lower()))
		if Global.get_flag(button.name.to_lower()):
			button.show()
			has_revives=true
		else:
			button.hide()
	if firstdeath and has_revives and main.num_enemies()>0:
		timer.timeout.connect(allowrevive)
	else:
		Global.set_permanent_data("global","player_dead",true)
		if Global.endless:
			main.save_data()
		else:
			Global.set_permanent_data("global","deaths",Global.get_permanent_data("global","deaths")+1)
		Global.reset_to_checkpoint()
		gameover.visible=true
		timer.wait_time=3
		timer.timeout.connect(start_fade)
	timer.start()
	$Health.maxhp=maxhp
	$Health.hp=0
	$Health.prevhp=0
	#revive.text=Global.load_config("bindings","attack")+": Revive as "+inventory.revivenames[inventory.revival]+"\n"+Global.load_config("bindings","secondary")+": Restart"

func allowrevive():
	revive.visible=true
	canrevive=true

func start_fade():
	main.fade_out(true)
	timer.wait_time=1
	timer.timeout.disconnect(start_fade)
	timer.timeout.connect(restart)
	timer.start()

func restart():
	Global.reset_game()

func switch_to_dead():
	Global.set_permanent_data("global","player_dead",true)
	if Global.endless:
		main.save_data()
	else:
		Global.set_permanent_data("global","deaths",Global.get_permanent_data("global","deaths")+1)
	Global.reset_to_checkpoint()
	revive.visible=false
	gameover.visible=true
	timer.timeout.disconnect(allowrevive)
	timer.timeout.connect(start_fade)
	timer.start()

func revive_as(button_name):
	if !main:
		return
	Global.slow_down_to_zero=false
	var scene=load("res://Scenes/Allies/"+button_name+"_controlled.tscn")
	inventory.revival=button_name
	if scene==null:
		scene=load("res://Scenes/Allies/roly_poly_controlled.tscn")
		inventory.revival="roly_poly"
	var player=scene.instantiate()
	player.global_position=tessa.global_position
	tessa.queue_free()
	player.original_player=false
	main.add_child(player)
	main.player=player
	queue_free()

func _process(_delta):
	if !gameover.visible:
		if get_tree().paused:
			revive.visible=false
		elif canrevive:
			revive.visible=true
	if !revive.visible or !canrevive:
		return
	#revive.text=Global.load_config("bindings","attack")+": Revive as "+inventory.revivenames[inventory.revival]+"\n"+Global.load_config("bindings","secondary")+": Restart"

func save_data():
	var data = {
		"path":scene_file_path,
		"pos_x":global_position.x,
		"pos_y":global_position.y,
		"maxhp":maxhp
	}
	return data

func load_data(data):
	add_to_group("to_save")
	global_position.x=data["pos_x"]
	global_position.y=data["pos_y"]
	maxhp=data["maxhp"]
	$Health.maxhp=maxhp
