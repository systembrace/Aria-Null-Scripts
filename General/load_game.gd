extends Node2D

func _draw():
	get_tree().create_timer(0.1).timeout.connect(load)

func load():
	for folder in DirAccess.get_directories_at("res://Scenes/"):
		for file in DirAccess.get_files_at("res://Scenes/"+folder):
			if !file.ends_with(".tscn"):
				continue
			load("res://Scenes/"+folder+"/"+file).instantiate()
	get_tree().call_deferred("change_scene_to_packed",load("res://Scenes/UI/main_menu.tscn"))
