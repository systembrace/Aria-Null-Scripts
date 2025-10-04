extends Node2D

func _ready():
	if not Global.endless and not FileAccess.file_exists("user://last_scene.dat"):# or true:
		var scenefile = FileAccess.open("user://last_scene.dat", FileAccess.WRITE)
		scenefile.store_string("res://maps/directory/startroom.tscn")
		#scenefile.store_string("res://maps/Endless.tscn")
		scenefile.close()
		var checkpoint = FileAccess.open("user://checkpoint_scene.dat", FileAccess.WRITE)
		checkpoint.store_string("res://maps/directory/startroom.tscn")
		#checkpoint.store_string("res://maps/Endless.tscn")
		checkpoint.close()
	
	if not FileAccess.file_exists("user://last_data.dat") or Global.get_flag("version")!=Global.version:# or true:
		var inventory=load("res://Scenes/General/inventory.tscn").instantiate()
		if Global.get_flag("version")!=Global.version and FileAccess.file_exists("user://checkpoint_data.dat"):
			var invfile=FileAccess.open("user://checkpoint_data.dat", FileAccess.READ)
			var node_name=""
			var data
			var json = JSON.new()
			while invfile.get_position() < invfile.get_length() and node_name!="Inventory":
				var contents = invfile.get_line()
				if json.parse(contents) != OK:
					print("JSON Parse Error: ", json.get_error_message(), " in ", contents, " at line ", json.get_error_line())
				data = json.data
				node_name=data["name"]
			if node_name=="Inventory":
				inventory.load_data(data)
			invfile.close()
		var lastfile = FileAccess.open("user://last_data.dat", FileAccess.WRITE)
		var cpfile = FileAccess.open("user://checkpoint_data.dat", FileAccess.WRITE)
		var save_data = {"path":"res://Scenes/Non-enemies/player.tscn","name":"Player","pos_x":0,"pos_y":8,"health":5,"original":true}
		#var save_data = {"path":"Scenes/Non-enemies/player.tscn","name":"Player","pos_x":192,"pos_y":816,"health":5,"original":true}
		var json_string = JSON.stringify(save_data)
		cpfile.store_line(json_string)
		lastfile.store_line(json_string)
		save_data = inventory.save_data()
		json_string = JSON.stringify(save_data)
		lastfile.store_line(json_string)
		lastfile.close()
		cpfile.store_line(json_string)
		cpfile.close()
		Global.set_flag("version",Global.version)
		Global.save_flags(true)
	
	Global.player_dead=false
	var scene
	if !Global.endless:
		var file = FileAccess.open("user://checkpoint_scene.dat",FileAccess.READ)
		Global.checkpoint_scene=file.get_as_text()
		file.close()
		file = FileAccess.open("user://last_scene.dat", FileAccess.READ)
		scene = load(file.get_as_text())
		file.close()
	if Global.endless:
		scene=load("res://maps/Endless.tscn")
	get_tree().call_deferred("change_scene_to_packed",scene)
