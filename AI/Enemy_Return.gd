extends State
class_name EnemyReturn

@export var navigator:Navigator
var spawn: Vector2
var speed
var accel
var direction=Vector2.ZERO

func enter():
	spawn=body.spawn
	speed=body.max_speed
	accel=body.accel

func update(_delta):
	direction=navigator.next_direction(spawn)
	if body.global_position.distance_to(spawn)<8:
		transition.emit(self,"Wander")

func physics_update(delta):
	body.velocity=body.velocity.move_toward(direction*speed,accel*60*delta)

func exit():
	pass
	#body.velocity=Vector2.ZERO
