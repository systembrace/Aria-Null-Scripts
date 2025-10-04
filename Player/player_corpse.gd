extends Interactable
class_name PlayerCorpse

func _ready():
	if randf()>.5:
		sprite.flip_h=true
	$Smoke.emitting=true

func revive():
	#var main=get_tree().get_root().get_node("Main")
	#var scene=load("res://Scenes/Non-enemies/player.tscn")
	#var player: Node2D =scene.instantiate()
	#player.global_position=global_position
	#player.original_player=true
	#main.add_child(player)
	#queue_free()
	pass

func save_data():
	var data = {
		"path":scene_file_path,
		"pos_x":global_position.x,
		"pos_y":global_position.y,
	}
	return data

func load_data(data):
	add_to_group("to_save")
	global_position.x=data["pos_x"]
	global_position.y=data["pos_y"]
