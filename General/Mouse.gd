extends Sprite2D
class_name Mouse

func _process(_delta):
	global_position=get_global_mouse_position()
