extends Entity
class_name Decoration

@export var flipped=false

func _ready():
	for child in get_children():
		if child is Rope and randf()>.75:
			child.hide()
	if flipped:
		for child in get_children():
			if child is AnimatedSprite2D or child is Sprite2D:
				child.flip_h=true
			if child is Rope:
				child.end.position.x*=-1
				child.global_position+=Vector2.LEFT
				child.recalc()
				child.queue_redraw()
			child.global_position.x=global_position.x-to_local(child.global_position).x
	super._ready()
