extends Node
class_name Globals

signal saving
signal environment_updated
signal dialogue_ended
var version=2
var player_dead=false
var flags = {}
var config=ConfigFile.new()
var shaketime:SceneTreeTimer
var shakeamt=1
var can_hitstop=true
var load_game=true
var endless=false
var checkpoint_scene
var environment: Environment
var wind_dir=0
var wind_step=PI
var wind_speed_step=0
var wind_speed=1
var num_particles=0
var items_list=["Grenades","Earthshaker"]
var guns_list=["Shield","Pistol","Shotgun","Harpoon"]
var revives_list=["none","roly_poly","elite"]

var defaults={
	"max_particles":1000,
	"attack_to_cursor":true,
	"dash_to_cursor":false,
	"shoot_to_cursor":true,
	"damage_values":true,
	"arena_with_cherry":false,
	"left":"A",
	"right":"D",
	"up":"W",
	"down":"S",
	"attack":"Mouse 1",
	"secondary":"Mouse 2",
	"dash":"Shift",
	"heal":"Q",
	"use item":"Space",
	"aim":"P",
	"next item":"Alt",
	"next gun":"Ctrl",
	"interact":"E",
	"inventory":"Tab",
	"back":"Escape",
	"pause":"Escape",
	"sfx":-2.4987,
	"music":-2.4987,
	"brightness":1.0,
	"screenshake":1.0,
	"hitstop":1.0,
	"window_mode":0
}

func snap_vector_angle(vec:Vector2, snap:float=PI/2):
	return Vector2.RIGHT.rotated(snappedf(vec.angle(),snap))*vec.length()

func _ready():
	seed(23017031)
	for file in DirAccess.get_files_at("res://"):
		if file.ends_with(".tscn"):
			var node=load(file).instantiate()
			node.queue_free()
	if not FileAccess.file_exists("user://last_flags.dat"):
		flags={"endlesshs":0,"version":version}
		save_flags(true)
	else:
		if not FileAccess.file_exists("user://last_scene.dat"):
			delete_all_save_data()
		else:
			load_flags()
	if not FileAccess.file_exists("user://config.ini"):# or true:
		load_config("game","max_particles")
		load_config("game","attack_to_cursor")
		load_config("game","dash_to_cursor")
		load_config("game","shoot_to_cursor")
		load_config("game","damage_values")
		load_config("game","arena_with_cherry")
		load_config("bindings","left")
		load_config("bindings","right")
		load_config("bindings","up")
		load_config("bindings","down")
		load_config("bindings","attack")
		load_config("bindings","secondary")
		load_config("bindings","dash")
		load_config("bindings","heal")
		load_config("bindings","use item")
		load_config("bindings","aim")
		load_config("bindings","next item")
		load_config("bindings","next gun")
		load_config("bindings","interact")
		load_config("bindings","inventory")
		load_config("bindings","back")
		load_config("bindings","pause")
		load_config("audio","sfx")
		load_config("audio","music")
		load_config("video","brightness")
		load_config("video","screenshake")
		load_config("video","hitstop")
		load_config("video","window_mode")
	else:
		config.load("user://config.ini")
	set_input_map(load_keybinds())
	change_window_mode()
	environment=Environment.new()
	environment.background_mode=Environment.BG_CANVAS
	environment.adjustment_enabled=true
	environment.adjustment_brightness=load_config("video","brightness")
	environment.glow_enabled=true
	environment.glow_blend_mode=Environment.GLOW_BLEND_MODE_SCREEN
	environment.glow_hdr_threshold=1

func delete_save(type):
	if FileAccess.file_exists("user://checkpoint_"+type+".dat"):
		DirAccess.remove_absolute("user://checkpoint_"+type+".dat")
	if FileAccess.file_exists("user://last_"+type+".dat"):
		DirAccess.remove_absolute("user://last_"+type+".dat")
		
func delete_all_save_data():
	load_flags()
	var hs=get_flag("endlesshs")
	delete_save("flags")
	delete_save("data")
	delete_save("scene")
	if DirAccess.dir_exists_absolute("user://area_data"):
		for path in DirAccess.get_files_at("user://area_data"):
			DirAccess.remove_absolute("user://area_data/"+path)
		DirAccess.remove_absolute("user://area_data")
	flags={"endlesshs":hs,"version":version}
	save_flags(true)
	
func revert_save(cp,last):
	if !FileAccess.file_exists("user://"+cp+".dat"):
		print("Checkpoint data not found for "+cp)
		return
	var file = FileAccess.open("user://"+cp+".dat", FileAccess.READ)
	var contents = file.get_as_text()
	file.close()
	file = FileAccess.open("user://"+last+".dat", FileAccess.WRITE)
	file.store_string(contents)
	file.close()

func revert_area_data():
	if !DirAccess.dir_exists_absolute("user://area_data"):
		return
	for file in DirAccess.get_files_at("user://area_data"):
		if file.begins_with("last_"):
			DirAccess.remove_absolute("user://area_data/"+file)
	for file in DirAccess.get_files_at("user://area_data"):
		if file.begins_with("checkpoint_"):
			var data=ConfigFile.new()
			data.load("user://area_data/"+file)
			data.save("user://area_data/last_"+file.substr(11))

func reset_to_checkpoint():
	player_dead=true
	load_game=true
	if endless:
		return
	revert_save("checkpoint_flags","last_flags")
	revert_save("checkpoint_data","last_data")
	revert_save("checkpoint_scene","last_scene")
	revert_area_data()
	load_flags()

func reset_game():
	get_tree().paused=false
	var main=get_tree().get_root().get_node("Main")
	get_tree().get_root().call_deferred("remove_child",main)
	get_tree().call_deferred("change_scene_to_packed",load("res://Scenes/General/game_start.tscn"))

func save_area_data():
	if !DirAccess.dir_exists_absolute("user://area_data"):
		return
	for file in DirAccess.get_files_at("user://area_data"):
		if file.begins_with("last_"):
			var data=ConfigFile.new()
			data.load("user://area_data/"+file)
			data.save("user://area_data/checkpoint_"+file.substr(5))

func get_flag(key,default=0):
	if endless and (key in items_list or key in guns_list or key in revives_list):
		return 1
	if key in flags.keys():
		return flags[key]
	if key=="version":
		set_flag("version",-1)
		save_flags(true)
		return -1
	set_flag(key,default)
	save_flags(true)
	return 0

func set_flag(key,value):
	flags[key]=value

func load_flags():
	var file = FileAccess.open("user://last_flags.dat", FileAccess.READ)
	var json = JSON.new()
	var contents = file.get_as_text()
	if json.parse(contents) != OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", contents, " at line ", json.get_error_line())
	else:
		flags=json.data

func save_flags(checkpoint=false,autosave=false):
	if !autosave:
		saving.emit()
	var file = FileAccess.open("user://last_flags.dat", FileAccess.WRITE)
	var json_string = JSON.stringify(flags)
	file.store_string(json_string)
	file.close()
	if !checkpoint:
		return
	file = FileAccess.open("user://checkpoint_flags.dat", FileAccess.WRITE)
	json_string = JSON.stringify(flags)
	file.store_string(json_string)
	file.close()

func save_data(data,scene_path,checkpoint=false,autosave=false):
	if !autosave:
		saving.emit()
	var file = FileAccess.open("user://last_data.dat", FileAccess.WRITE)
	file.store_string(data)
	file.close()
	file = FileAccess.open("user://last_scene.dat", FileAccess.WRITE)
	file.store_string(scene_path)
	file.close()
	if !checkpoint:
		return
	file = FileAccess.open("user://checkpoint_data.dat", FileAccess.WRITE)
	file.store_string(data)
	file.close()
	file = FileAccess.open("user://checkpoint_scene.dat", FileAccess.WRITE)
	file.store_string(scene_path)
	file.close()

func save_options(autosave=false):
	if !autosave:
		saving.emit()
	config.save("user://config.ini")

func save_config(section,field,value):
	config.set_value(section,field,value)

func load_config(section,field):
	if config.has_section_key(section,field):
		return config.get_value(section,field)
	save_config(section,field,defaults[field])
	return defaults[field]

func save_keybinds(bindings):
	for action in bindings.keys():
		config.set_value("bindings",action,bindings[action])
	save_options()

func load_keybinds():
	var bindings={}
	for action in config.get_section_keys("bindings"):
		bindings[action]=config.get_value("bindings",action)
	return bindings

func set_input_map(bindings):
	for action in bindings.keys():
		InputMap.action_erase_events(action)
		var event_str=bindings[action]
		var event
		if "Mouse" in bindings[action]:
			event=InputEventMouseButton.new()
			event.button_index=int(event_str.split(" ")[1])
		else:
			event=InputEventKey.new()
			event.keycode=OS.find_keycode_from_string(event_str)
		InputMap.action_add_event(action,event)

func hitstop(duration,bypass=false):
	var hitstop_mod=config.get_value("video","hitstop")
	if !hitstop_mod:
		hitstop_mod=1
	if can_hitstop or bypass:
		can_hitstop=false
		var timer = get_tree().create_timer(duration*hitstop_mod,true,false,true)
		get_tree().paused=true
		await timer.timeout
		get_tree().paused=false
		var metatimer = get_tree().create_timer(duration*hitstop_mod*2,true,false,true)
		metatimer.timeout.connect(enable_hitstop)
	
func enable_hitstop():
	can_hitstop=true

func slowdown(duration, time_scale=0.05):
	Engine.time_scale=time_scale
	var timer = get_tree().create_timer(duration*time_scale)
	await timer.timeout
	Engine.time_scale = 1
	
func screenshake(time=.1,amount=1):
	shaketime=get_tree().create_timer(time,true,false,false)
	shaketime.timeout.connect(stopshake)
	shakeamt=amount

func stopshake():
	shaketime=null

func can_create_particle():
	return num_particles<load_config("game","max_particles")

func change_window_mode():
	var mode=load_config("video","window_mode")
	var viewport=get_window()
	if mode==0 and DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		viewport.content_scale_stretch=Window.CONTENT_SCALE_STRETCH_INTEGER
		viewport.unresizable=true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif mode==1 and DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_WINDOWED:
		viewport.content_scale_stretch=Window.CONTENT_SCALE_STRETCH_FRACTIONAL
		viewport.unresizable=false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		viewport.size=Vector2i(480,270)
		while viewport.size+Vector2i(480,270)<DisplayServer.screen_get_size():
			viewport.size+=Vector2i(480,270)
		viewport.position=(DisplayServer.screen_get_size()-viewport.size)/2

func _process(delta):
	if wind_dir!=0:
		wind_speed_step+=delta*.7
		if wind_speed_step>2*PI:
			wind_speed_step-=2*PI
		wind_speed=sin(.5*wind_speed_step)*cos(1.5*wind_speed_step)*cos(2*wind_speed_step)+.5
		wind_step+=delta*wind_speed
		if (wind_speed)<.2:
			wind_step=move_toward(wind_step,PI*(wind_dir+1)/2,delta*5)
		if wind_step>2*PI:
			wind_step-=2*PI
	if shaketime:
		var shake_mod=config.get_value("video","screenshake")
		get_viewport().get_camera_2d().offset=Vector2(randi_range(-shakeamt*shake_mod,shakeamt*shake_mod),randi_range(-shakeamt*shake_mod,shakeamt*shake_mod))
	elif get_viewport().get_camera_2d():
		get_viewport().get_camera_2d().offset=Vector2(.1,0)
