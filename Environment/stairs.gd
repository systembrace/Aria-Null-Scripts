extends Area2D
class_name Stairs

@export var direction=-1

func _ready():
	set_collision_layer_value(1,false)
	set_collision_layer_value(27,true)
	set_collision_mask_value(1,false)
