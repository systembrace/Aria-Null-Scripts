extends Node2D
class_name Spawner

@export var enemy_name="default"
@export var spawn_time=3.0
signal spawned
var activated=false
@onready var timer=$Timer

func _ready():
	if spawn_time>0:
		$Sprite.scale=Vector2(2,2)
		$Sprite.play()
		spawn_time+=randf_range(-spawn_time/2,spawn_time/2)
		timer.wait_time=spawn_time
		timer.timeout.connect(spawn)
		timer.start()
		return
	$Sprite.flip_h=randi_range(0,1)
	$Sprite.animation=enemy_name
	$Sprite.animation_finished.connect(spawn)
	
func activate():
	activated=true
	$Sprite.play()
	find_child("SFX_"+enemy_name).play()
	
func spawn():
	if spawn_time>0:
		var sfx=$Spawn.duplicate()
		sfx.global_position=global_position
		sfx.finished.connect(sfx.queue_free)
		get_parent().call_deferred("add_child",sfx)
		sfx.call_deferred("play")
	var scene=load("res://Scenes/Enemies/"+enemy_name+".tscn")
	var instance=scene.instantiate()
	instance.global_position=global_position
	if spawn_time<=0:
		instance.dont_notice=true
	get_parent().call_deferred("add_child",instance)
	spawned.emit(instance)
	if enemy_name!="roly_poly":
		var searchfield = instance.find_child("SearchField")
		searchfield.radius=256
		searchfield.see_through_walls=true
	queue_free()
