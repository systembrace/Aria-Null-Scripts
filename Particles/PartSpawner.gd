extends Node2D
class_name PartSpawner

@export var bullet=false
@export var particles={}
var main

func _ready():
	main=get_tree().get_root().get_node("Main")

func spawn(parry=false,pos=get_parent().global_position,mod=1):
	if not main:
		return
	for pname in particles.keys():
		spawn_spec(pname,pos,parry,mod)

func spawn_spec(pname,pos=get_parent().global_position,parry=false,mod=1,blood_for_corpse=false):
	if not main:
		return
	var mn=particles[pname].x*mod
	var mx=particles[pname].y*mod
	var scene=load("res://Scenes/Particles/"+pname+".tscn")
	if pname=="blood" and parry and not bullet and not blood_for_corpse:
		mn=8
		mx=8
	for i in range(0,randi_range(mn,mx)):
		var instance=scene.instantiate()
		instance.global_position=pos
		if pname=="blood":
			instance.parry=parry
			instance.corpse=blood_for_corpse
		if pname=="rubble":
			instance.vel_mod=mod
		main.call_deferred("add_child",instance)

func heal_corpse():
	if not main or not main.player_corpse:
		return
	spawn_spec("blood",get_parent().global_position,true,1,main.player_corpse)
