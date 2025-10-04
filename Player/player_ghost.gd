extends CharacterBody2D
class_name PlayerGhost

var target
var main
var inventory: Inventory
var maxhp=5
var firstdeath=true
var canrevive=false
@onready var timer = $DeathTimer
@onready var revive=$CanvasLayer/Revive
@onready var gameover=$CanvasLayer/GameOver

func _ready():
	main=get_tree().get_root().get_node("Main")
	timer.wait_time=2
	if firstdeath and inventory.revival!="none":
		timer.timeout.connect(allowrevive)
	else:
		Global.player_dead=true
		if Global.endless:
			main.save_data()
		Global.reset_to_checkpoint()
		gameover.visible=true
		timer.timeout.connect(start_fade)
	timer.start()
	$Health.maxhp=maxhp
	$Health.hp=0
	$Health.prevhp=0
	revive.text=Global.load_config("bindings","attack")+": Revive as "+inventory.revivenames[inventory.revival]+"\n"+Global.load_config("bindings","secondary")+": Restart"

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
	Global.player_dead=true
	if Global.endless:
		main.save_data()
	Global.reset_to_checkpoint()
	revive.visible=false
	gameover.visible=true
	timer.timeout.disconnect(allowrevive)
	timer.timeout.connect(start_fade)
	timer.start()

func _process(_delta):
	if !gameover.visible:
		if get_tree().paused:
			revive.visible=false
		elif canrevive:
			revive.visible=true
	if !revive.visible or !canrevive:
		return
	revive.text=Global.load_config("bindings","attack")+": Revive as "+inventory.revivenames[inventory.revival]+"\n"+Global.load_config("bindings","secondary")+": Restart"
	if Input.is_action_just_released("secondary"):
		switch_to_dead()
		return
	if Input.is_action_just_released("attack"):
		if !main:
			return
		if inventory.revival=="none":
			switch_to_dead()
			return
		var scene=load("res://Scenes/Non-enemies/"+inventory.revival+"_controlled.tscn")
		if scene==null:
			scene=load("res://Scenes/Non-enemies/enemy_controlled.tscn")
		var player=scene.instantiate()
		player.global_position=global_position
		player.original_player=false
		main.add_child(player)
		main.player=player
		$CustomParticleSpawner.spawn()
		var sparks=$Sparks.duplicate()
		sparks.global_position=global_position
		sparks.finished.connect(sparks.queue_free)
		main.add_child(sparks)
		sparks.process_material.direction=Vector3(0,-2,0)
		sparks.emitting=true
		queue_free()

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
