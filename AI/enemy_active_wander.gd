extends State
class_name EnemyActiveWander

@export var navigator: Navigator
@export var turn_range=1.0
@export var wall_avoidance=1.0
@export var run_from_target=0.0
var wander_to=Vector2.ZERO
var direction=Vector2.ZERO
var speed
var accel
@onready var ray=$RayCast2D

func enter():
	speed=body.max_speed
	accel=body.accel
	wander_to=body.global_position
	direction=Vector2.UP.rotated(randi_range(0,7)*PI/4)
	
func update():
	if navigator.nav_agent.is_navigation_finished():
		wander_to+=body.velocity.normalized().rotated(randf_range(-turn_range,turn_range)*PI/4)*8
		ray.global_position=body.global_position
		ray.target_position=(wander_to-body.global_position)*wall_avoidance
		ray.force_raycast_update()
		if ray.is_colliding():
			wander_to=body.global_position
	if run_from_target>0 and is_instance_valid(body.target):
		var target=body.target
		var dist_vec=body.to_local(target.global_position)
		if dist_vec.length()<=run_from_target and dist_vec.length()>8:
			wander_to=body.global_position-speed*dist_vec.normalized()/(max(dist_vec.length(),run_from_target/2)/run_from_target)*.5
	direction=navigator.next_direction(wander_to)

func physics_update():
	body.velocity=body.velocity.move_toward(direction*speed,accel)
