extends State
class_name EnemyFollow

@export var attack_dist: float = 192
@export var navigator:Navigator
@export var searchfield:SearchField
var target: Node2D
var direction=Vector2.ZERO
var speed
var accel

func enter():
	speed=body.max_speed
	accel=body.accel
	target=body.target

func update():
	if target!=body.target:
		target=body.target
	if not is_instance_valid(target):
		transition.emit(self,"Wander")
		return
	if target is Enemy and speed==body.max_speed:
		speed+=16
	var targetdist=body.global_position.distance_to(target.global_position)
	if (targetdist<attack_dist and (not body is Ally or target.target==body)) or (body is Ally and targetdist<24):
		transition.emit(self,"Attack")
		direction=Vector2.ZERO
	else:
		direction=navigator.next_direction(target.global_position)

func physics_update():
	body.velocity=body.velocity.move_toward(direction*speed,accel)

func exit():
	pass
	#body.velocity=Vector2.ZERO
