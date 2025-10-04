extends Area2D

@onready var radius=$CollisionShape2D.shape.height

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body!=get_parent():
			var direction=to_local(body.global_position)
			if direction.length()<.5:
				return
			body.velocity+=direction*radius/direction.length()
