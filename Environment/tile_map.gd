extends Node2D
class_name EnvTileMap

func get_used_rect():
	var rect=Rect2i(0,0,0,0)
	for child in get_children():
		if child is TileMapLayer:
			rect=rect.merge(child.get_used_rect())
	return rect
