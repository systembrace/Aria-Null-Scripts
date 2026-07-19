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
var inventory: Inventory
var player_corpse: PlayerCorpse
var npcs: Dictionary[String, Entity] = {}
var current_waypoint: Waypoint
var transition:FadeTransition
var canvasmod:CanvasModulate
var worldenv:WorldEnvironment
@onready var nav_map=$NavMap

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
		var area=scene_file_path.substr(scene_file_path.to_lower().find("maps/")+5)
		scene_name=area.substr(area.find("/")+1)
		scene_name=scene_name.substr(0,scene_name.find("."))
		area=area.substr(0,area.find("/"))
		config_name="user://area_data/last_"+area+".ini"
		checkpoint_config_name="user://area_data/checkpoint_"+area+".ini"
		load_objects()
	worldenv=WorldEnvironment.new()
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
		if obj is Enemy or obj is Spawner:
			config.set_value(scene_name,obj.name,"alive")
		elif obj is Ally:
			config.set_value(scene_name,obj.name,var_to_str(obj.global_position))
			config.set_value(scene_name,obj.name+"_dir",var_to_str(obj.find_child("AnimationController").direction))
		elif obj is Breakable:
			if obj.broken:
				config.set_value(scene_name,obj.name,"broken")
		elif obj is BreakableWall:
			config.set_value(scene_name,obj.name,"unbroken")
		elif obj is FadeTransition:
			config.set_value(scene_name,obj.name,"undiscovered")
		elif obj is Door:
			config.set_value(scene_name,obj.name,obj.opened)
		elif obj is InteractPanel:
			config.set_value(scene_name,obj.name,obj.disabled)
		elif obj is EventSequence:
			if obj.active=="First":
				obj.active=obj.events[0].name
			config.set_value(scene_name,obj.name,obj.active)
			var waypoint_name="none"
			if current_waypoint:
				waypoint_name=current_waypoint.name
			config.set_value(scene_name,"current waypoint",waypoint_name)
		elif obj is RepeatingEvent:
			config.set_value(scene_name,obj.name,obj.current)
		elif obj is Pickup:
			config.set_value(scene_name,obj.name,obj.visible)
		elif obj is NPCEventController:
			var temp_config=ConfigFile.new()
			var section=obj.npc_name
			var npc_config="user://area_data/last_npcs.ini"
			if FileAccess.file_exists(npc_config):
				temp_config.load(npc_config)
				if temp_config.has_section(section):
					temp_config.erase_section(section)
			temp_config.set_value(section,"interact_count",obj.interact_count)
			temp_config.set_value(section,"reactions_given",var_to_str(obj.reactions_given))
			temp_config.save("user://area_data/last_npcs.ini")
			if checkpoint:
				temp_config.save("user://area_data/checkpoint_npcs.ini")
		elif obj is PushBlock:
			config.set_value(scene_name,obj.name+"_rot",obj.rotation)
			config.set_value(scene_name,obj.name+"_pos",var_to_str(obj.global_position))
			config.set_value(scene_name,obj.name,obj.occupying.get_path())
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
				if obj is Enemy or obj is FadeTransition or obj is BreakableWall or obj is Spawner:
					obj.queue_free()
				if obj is NPCEventController:
					var temp_config=ConfigFile.new()
					var npc_config="user://area_data/last_npcs.ini"
					if !FileAccess.file_exists(npc_config):
						continue
					temp_config.load(npc_config)
					if !temp_config.has_section(obj.npc_name):
						continue
					obj.interact_count=temp_config.get_value(obj.npc_name,"interact_count")
					obj.reactions_given=str_to_var(temp_config.get_value(obj.npc_name,"reactions_given"))
			elif obj.name in config.get_section_keys(scene_name):
				if obj is Enemy or obj is FadeTransition or obj is Spawner:
					continue
				elif obj is Ally:
					obj.global_position=str_to_var(config.get_value(scene_name,obj.name))
					obj.find_child("AnimationController").direction=str_to_var(config.get_value(scene_name,obj.name+"_dir"))
				elif obj is EventSequence:
					obj.set_active(config.get_value(scene_name,obj.name))
					var waypoint_name=config.get_value(scene_name,"current waypoint","none")
					if waypoint_name!="none":
						current_waypoint=find_child(waypoint_name)
				elif obj is Door:
					obj.snap_to_init(config.get_value(scene_name,obj.name))
				elif obj is InteractPanel:
					if config.get_value(scene_name,obj.name):
						if obj.save_press:
							obj.interact()
						else:
							obj.disable()
					else:
						obj.turn_on()
						obj.turn_off()
				elif obj is Breakable and config.get_value(scene_name,obj.name)=="broken":
					var new_breakables=obj.set_broken()
					if new_breakables:
						for breakable in new_breakables:
							if breakable.name in config.get_section_keys(scene_name) and config.get_value(scene_name,breakable.name)=="broken":
								breakable.set_broken()
				elif obj is RepeatingEvent:
					obj.current=config.get_value(scene_name,obj.name)
				elif obj is Pickup:
					obj.visible=config.get_value(scene_name,obj.name)
					if obj.visible:
						obj.settle()
						obj.reparent(self)
				elif obj is PushBlock:
					obj.occupying.occ_by=null
					obj.rotation=config.get_value(scene_name,obj.name+"_rot")
					obj.global_position=str_to_var(config.get_value(scene_name,obj.name+"_pos"))
					obj.occupying=get_tree().get_root().get_node(config.get_value(scene_name,obj.name))
					obj.occupying.occ_by=obj
			else:
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
	for node in get_tree().get_nodes_in_group("prevent_save"):
		if !node.can_save():
			return false
	return num_enemies(true)==0 and not Global.get_permanent_data("global","player_dead") and inventory.hud.dialogue_box.current_section==""

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
	data+=JSON.stringify(player.save_data())+"\n"
	for node in get_tree().get_nodes_in_group("to_save"):
		if node is Player:
			continue
		if node is Inventory:
			node.scrap+=scrap
		var node_data = node.save_data()
		var json_string = JSON.stringify(node_data)
		data+=json_string+"\n"
	Global.save_data(data,scene_file_path,checkpoint,autosave)
	Global.save_options(autosave)
	if save_object_status:
		save_objects(checkpoint)

func fade_out(total_fade=false,speed=.1):
	if total_fade:
		transition.get_parent().layer=1026
	transition.reverse_fade(speed)

func exit():
	#now saved in transition.gd
	#if save_object_status:
	#	save_objects()
	queue_free()
