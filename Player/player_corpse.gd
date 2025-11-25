extends CharacterBody2D
class_name PlayerCorpse

var main
@onready var sprite=$AnimatedSprite2D

func _ready():
	if randf()>.5:
		sprite.flip_h=true
	$Smoke.emitting=true
	main=get_tree().get_root().get_node("Main")
	main.player_corpse=self

func revive(tessa):
	var scene=load("res://Scenes/Allies/player.tscn")
	var player: Node2D =scene.instantiate()
	player.global_position=global_position
	player.original_player=true
	player.revive=true
	player.tessa=tessa
	main.add_child(player)
	main.player=player
	main.player_corpse=null
	queue_free()

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
