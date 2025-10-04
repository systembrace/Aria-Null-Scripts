extends Area2D
class_name Transition

@export var scene_name = "start_area/startroom"
@export var pos = Vector2(0,8)
@export var walk_direction=Vector2.DOWN
@export var exit_direction=Vector2.UP
var player:Player
var inventory:Inventory
var main
var scene

func _ready():
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	set_collision_mask_value(17,true)
	body_entered.connect(on_body_entered)
	body_exited.connect(change_scene)
	main=get_tree().get_root().get_node("Main")

func on_body_entered(body):
	if body is Player and is_instance_valid(main):
		player=body
		inventory=player.inventory
		player.control.set_process(false)
		player.control.paused=true
		player.velocity=walk_direction*player.speed
		main.fade_out()

func set_main(node):
	if node.get("main"):
		node.main=scene
	for child in node.get_children():
		if child.get("main"):
			child.main=scene
		else:
			set_main(child)

func node_children_recursive(node,previous):
	for child in node.get_children():
		if child is Scrap:
			inventory.scrap+=1
			child.queue_free()
		if child is SoundPlayer and child.is_playing() and not child.fade:
			var sound=child.duplicate()
			sound.time_between_plays=0
			scene.add_child(sound)
			sound.fade=true
			sound.global_position=pos+sound.global_position-previous
		else:
			node_children_recursive(child,previous)

func change_scene(_body=null):
	if !player:
		return
	player.set_process_input(false)
	main.hide()
	main.name="old_main"
	main.call_deferred("exit")
	scene=load("res://maps/"+scene_name+".tscn").instantiate()
	scene.scene_name=scene_name.substr(scene_name.find("/")+1)
	scene.name="Main"
	scene.remove_child(scene.find_child("Player"))
	scene.remove_child(scene.find_child("Inventory"))
	get_tree().get_root().call_deferred("add_child",scene)
	player.reparent(scene)
	inventory.reparent(scene)
	player.velocity=exit_direction*player.speed
	var timer=get_tree().create_timer(.1)
	timer.timeout.connect(player.control.set_deferred.bind("paused",false))
	timer.timeout.connect(player.control.set_process.bind(true))
	var previous=player.global_position
	player.global_position=pos
	player.prev_location=pos
	inventory.global_position=pos
	node_children_recursive(main,previous)
	set_main(player)
	set_main(inventory)
	inventory.hud.dialogue_box.exit(true)
	scene.player=player
	inventory.update_camera()
	player.call_deferred("make_scarf")
	Global.num_particles=0
