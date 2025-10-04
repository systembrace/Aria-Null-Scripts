extends Node2D
class_name Secondary

@export var numshots=15
var targetparent
var target
var cant_move=false

func equip(parent):
	targetparent=parent
	target=targetparent.target

func can_use():
	return true

func target_dir(override=Vector2.ZERO, angle=0):
	var pos=Vector2.RIGHT
	if is_instance_valid(target):
		pos=target.global_position
	if override!=Vector2.ZERO:
		pos=override
	var res=targetparent.to_local(pos)
	if is_instance_valid(target) and target is Mouse:
		if Global.load_config("game","shoot_to_cursor"):
			res-=Vector2.UP*19
		else:
			res=targetparent.dir
	else:
		res-=position/2
	return res.normalized().rotated(angle)

func use():
	pass
