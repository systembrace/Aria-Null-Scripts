extends Node2D
class_name Main

@export var tilemap: EnvTileMap
@export var save_object_status=false
@export var dark=false
@export var wind_dir=0
signal transitionfinished
signal player_healed
var config_name
var checkpoint_config_name
var scene_name=""
var player: Player
var current_waypoint: Waypoint
var transition:FadeTransition
var canvasmod:CanvasModulate

func _ready():
	#seed(23017031)
	y_sort_enabled=true
	if dark:
		canvasmod=CanvasModulate.new()
		canvasmod.color="3e3d3f"
		add_child(canvasmod)
	Global.wind_dir=wind_dir
	var started_game=false
	if Global.load_game:
		started_game=true
		load_from_save()
	if save_object_status:
		var area=scene_file_path.substr(scene_file_path.find("maps/")+5)
		if scene_name=="":
			scene_name=area.substr(area.find("/")+1)
			scene_name=scene_name.substr(0,scene_name.find("."))
		area=area.substr(0,area.find("/"))
		config_name="user://area_data/last_"+area+".ini"
		checkpoint_config_name="user://area_data/checkpoint_"+area+".ini"
		load_objects()
	var worldenv=WorldEnvironment.new()
	worldenv.environment=Global.environment
	add_child(worldenv)
	Global.environment_updated.connect(worldenv.set_deferred.bind("environment",Global.environment))
	var canvaslayer=CanvasLayer.new()
	canvaslayer.layer=0
	if started_game:
		canvaslayer.layer=1026
	add_child(canvaslayer)
	transition=load("res://Scenes/General/FadeTransition.tscn").instantiate()
	canvaslayer.add_child(transition)
	if started_game:
		transition.finished.connect(player.control.set_process.bind(true))
		transition.finished.connect(canvaslayer.set.bind("layer",0))
		transition.finished.connect(transitionfinished.emit)
		player.control.set_process(false)
	else:
		transition.fade_out()
	var temp=save_object_status
	save_object_status=false
	save_data(false,true)
	save_object_status=temp

func load_from_save():
	var file
	file = FileAccess.open("user://last_data.dat", FileAccess.READ)
	for node in get_tree().get_nodes_in_group("to_save"):
		node.free()
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var contents = file.get_line()
		if json.parse(contents) != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", contents, " at line ", json.get_error_line())
			return
		var data = json.data
		var node=load(data["path"]).instantiate()
		if node is Player:
			player=node
			player.healing.connect(player_healed.emit)
		node.load_data(data)
		add_child(node)
	file.close()
	Global.load_game=false

func save_objects(checkpoint=false):
	var config=ConfigFile.new()
	if FileAccess.file_exists(config_name):
		config.load(config_name)
		if config.has_section(scene_name):
			config.erase_section(scene_name)
	var namedict={}
	for obj in get_tree().get_nodes_in_group("objs_to_load"):
		if not obj.name in namedict.keys():
			namedict[obj.name]=0
		namedict[obj.name]+=1
		if namedict[obj.name]>1:
			print("Duplicate name found, fix required for enemy status to save")
		if obj is Enemy:
			config.set_value(scene_name,obj.name,"alive")
		elif obj is Ally:
			config.set_value(scene_name,obj.name,var_to_str(obj.global_position))
			config.set_value(scene_name,obj.name+"_dir",var_to_str(obj.find_child("AnimationController").direction))
		elif obj is Box:
			config.set_value(scene_name,obj.name,"unbroken")
		elif obj is BreakableWall:
			config.set_value(scene_name,obj.name,"unbroken")
		elif obj is FadeTransition:
			config.set_value(scene_name,obj.name,"undiscovered")
		elif obj is Door:
			config.set_value(scene_name,obj.name,obj.opened)
		elif obj is InteractPanel:
			config.set_value(scene_name,obj.name,obj.disabled)
		elif obj is EventSequence:
			config.set_value(scene_name,obj.name,obj.active)
			var waypoint_name="none"
			if current_waypoint:
				waypoint_name=current_waypoint.name
			config.set_value(scene_name,"current waypoint",waypoint_name)
		else:
			print("idk how to save this "+obj.name)
	config.set_value(scene_name,"Visited",true)
	config.save(config_name)
	if checkpoint:
		config.save(checkpoint_config_name)

func load_objects():
	if FileAccess.file_exists(config_name):
		var config=ConfigFile.new()
		config.load(config_name)
		if !config.has_section(scene_name):
			return
		for obj in get_tree().get_nodes_in_group("objs_to_load"):
			if not obj.name in config.get_section_keys(scene_name):
				if obj is Enemy or obj is FadeTransition or obj is Box or obj is BreakableWall:
					obj.queue_free()
					continue
			elif obj.name in config.get_section_keys(scene_name):
				if obj is Enemy or obj is FadeTransition:
					continue
				elif obj is Ally:
					obj.global_position=str_to_var(config.get_value(scene_name,obj.name))
					obj.find_child("AnimationController").direction=str_to_var(config.get_value(scene_name,obj.name+"_dir"))
					continue
				elif obj is EventSequence:
					obj.set_active(config.get_value(scene_name,obj.name))
					var waypoint_name=config.get_value(scene_name,"current waypoint","none")
					if waypoint_name!="none":
						current_waypoint=find_child(waypoint_name)
					continue
				elif obj is Door:
					obj.snap_to_init(config.get_value(scene_name,obj.name))
					continue
				elif obj is InteractPanel:
					if config.get_value(scene_name,obj.name):
						obj.disable()
					else:
						obj.turn_on()
						obj.turn_off()
					continue
			print("idk how to load this "+obj.name)
	else:
		if !DirAccess.dir_exists_absolute("user://area_data"):
			DirAccess.make_dir_absolute("user://area_data")
		save_objects()

func num_enemies(active=false):
	var res=0
	for child in get_children():
		if child is Spawner:
			res+=1
		if child is Enemy and (!active or is_instance_valid(child.target)):
			res+=1
	return res

func can_save():
	return num_enemies(true)==0 and not Global.player_dead

func save_data(checkpoint=false, autosave=false):
	Global.save_flags(checkpoint,autosave)
	if checkpoint:
		Global.checkpoint_scene=scene_file_path
		Global.save_area_data()
	var scrap=0
	for child in get_children():
		if child is Scrap:
			scrap+=1
			child.queue_free()
	var data=""
	for node in get_tree().get_nodes_in_group("to_save"):
		if node is Inventory:
			node.scrap+=scrap
		var node_data = node.save_data()
		var json_string = JSON.stringify(node_data)
		data+=json_string+"\n"
	Global.save_data(data,scene_file_path,checkpoint,autosave)
	Global.save_options(autosave)
	if save_object_status:
		save_objects(checkpoint)

func fade_out(total_fade=false):
	if total_fade:
		transition.get_parent().layer=1026
	transition.reverse_fade()

func exit():
	if save_object_status:
		save_objects()
	queue_free()
	#test
