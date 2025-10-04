extends State
class_name EnemyWander

@export var min_wander:float=1
@export var max_wander:float=2
@export var wander_radius=32
var spawn: Vector2
var direction: Vector2
var time_wander: float
var chase_radius
var speed
var accel
var wait=false
var far=false
@onready var timer=$WanderTime

func cycle():
	wait=not wait
	time_wander=randf_range(min_wander,max_wander)
	timer.wait_time=time_wander
	if not wait:
		if far:
			far=false
			direction=(spawn-body.global_position).rotated(randf_range(-PI/4,PI/4)).normalized()
		else:
			direction=Vector2.UP.rotated(randf_range(0,2*PI))
	else:
		direction=Vector2.ZERO
		timer.wait_time*=4
	timer.start()

func enter():
	wait=false
	spawn=body.spawn
	speed=body.max_speed
	accel=body.accel
	chase_radius=body.chase_radius
	cycle()

func update():
	if not wait and body.global_position.distance_to(spawn)>=wander_radius*2:
		transition.emit(self, "Return")
	if not wait and (body.global_position+direction*accel/2).distance_to(spawn)>wander_radius:
		far=true
		cycle()
func physics_update():
	body.velocity=body.velocity.move_toward(direction*speed/4,accel/2)

func exit():
	#body.velocity=Vector2.ZERO
	pass

func _on_timer_timeout():
	cycle()
