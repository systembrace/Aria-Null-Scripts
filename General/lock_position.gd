@tool
extends Node2D
class_name LockPosition

@export var set_position: Vector2
@export var dynamic_rotation=false

func _ready():
	global_position=get_parent().global_position+set_position

func _process(_delta):
	if dynamic_rotation:
		global_position=get_parent().global_position+set_position
