extends Node2D
class_name Spawner

@export var enemy_name="enemy"
@export var spawn_time=3.0
@onready var timer=$Timer

func _ready():
	
	$Sprite.play()
	spawn_time+=randf_range(-spawn_time/2,spawn_time/2)
	timer.wait_time=spawn_time
	timer.timeout.connect(spawn)
	timer.start()
	
func spawn():
	var sfx=$Spawn.duplicate()
	sfx.global_position=global_position
	sfx.finished.connect(sfx.queue_free)
	get_parent().call_deferred("add_child",sfx)
	sfx.call_deferred("play")
	var scene=load("res://Scenes/Enemies/"+enemy_name+".tscn")
	var instance=scene.instantiate()
	instance.global_position=global_position
	get_parent().call_deferred("add_child",instance)
	if enemy_name!="roly_poly":
		var searchfield = instance.find_child("SearchField")
		searchfield.radius=256
		searchfield.see_through_walls=true
	queue_free()
