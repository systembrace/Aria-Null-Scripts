@tool
extends Node2D
class_name LockRotation

@export var dynamic_rotation=false

func _ready():
	global_rotation=0

func _process(_delta):
	if dynamic_rotation:
		global_rotation=0
