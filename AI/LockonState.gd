extends State
class_name LockonState

@export var navigator: Navigator
@export var stay_away=false
@export var combat_dist=192
@export var min_dist=32
@export var max_dist=64
var dist=0
var pivot=0
var nextdist=0
var nextpivot=0
var destination:Vector2
var target:Node2D=null
var targetdist=99999
var speed
var accel
var direction=Vector2.ZERO
@onready var ray=$RayCast2D

func enter():
	if !is_instance_valid(body.target):
		transition.emit(self, "Wander")
		return
	if is_instance_valid(body.target):
		target=body.target
	speed=body.max_speed
	accel=body.accel
	reset_dest()

func reset_dest():
	destination=target.to_local(body.global_position).normalized()*max_dist+target.global_position
	pivot=target.to_local(body.global_position).angle()
	dist=max_dist
	nextdist=dist
	nextpivot=pivot

func reset_target():
	target=body.target
	if is_instance_valid(target):
		reset_dest()
	direction=Vector2.ZERO

func next_dest():
	if !can_see_target():
		nextdist=0
		return
	nextdist=randf_range(min_dist,max_dist)
	nextpivot=pivot+randf_range(PI/16,PI/8)*(randi_range(0,1)*2-1)
	while true:
		var tempdestination=target.global_position+Vector2.RIGHT.rotated(nextpivot)*min_dist
		raytarget(tempdestination, target.global_position)
		if !ray.is_colliding():
			break
		nextpivot+=PI/16
	if nextpivot>=2*PI:
		nextpivot-=2*PI

func raytarget(pos, start=body.global_position):
	ray.global_position=start
	ray.target_position=pos-start
	ray.force_raycast_update()

func can_see_target():
	if !is_instance_valid(target):
		return false
	raytarget(target.global_position)
	return !ray.is_colliding()

func update_targetdist():
	targetdist=body.to_local(target.global_position).length()

func update():
	#circle
	if (targetdist>max_dist+16 or (stay_away and targetdist<min_dist)) and can_see_target():
		reset_dest()
	elif body.to_local(destination).length()<16 or (!can_see_target() and nextdist!=0) or (nextdist==0 and can_see_target()):
		next_dest()
	if pivot!=nextpivot:
		pivot=lerp_angle(pivot,nextpivot,.1)
	if dist!=nextdist:
		dist=move_toward(dist,nextdist,1)
	destination=target.global_position+Vector2.RIGHT.rotated(pivot)*dist
	raytarget(destination, target.global_position)
	if ray.is_colliding():
		destination=ray.get_collision_point()
	direction=navigator.next_direction(destination)
