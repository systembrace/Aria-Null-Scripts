extends State
class_name LockonState

@export var navigator: Navigator
@export var try_stay_away=false
@export var combat_dist=192
@export var min_dist=32
@export var max_dist=64
@export var pivot_range_div=4
@export var can_jump=true
var dist=0
var pivot=0
var nextdist=0
var nextpivot=0
var destination:Vector2
var dist_to_dest=0
var target:Node2D=null
var targetdist=99999
var speed
var accel
var direction=Vector2.ZERO
var stay_away
@onready var ray:RayCast2D=$RayCast2D

func enter():
	if !is_instance_valid(body.target):
		transition.emit(self, "Wander")
		return
	stay_away=try_stay_away
	if is_instance_valid(body.target):
		target=body.target
	speed=body.max_speed
	accel=body.accel
	reset_dest()

func set_dest():
	destination=target.global_position+Vector2.RIGHT.rotated(pivot)*dist

func reset_dest():
	pivot=target.to_local(body.global_position).angle()
	dist=max_dist
	set_dest()
	nextdist=dist
	nextpivot=pivot

func reset_target():
	target=body.target
	if is_instance_valid(target):
		reset_dest()
	direction=Vector2.ZERO

func next_dest():
	if !can_see_target() or targetdist>combat_dist-16:
		nextdist=0
		return
	nextdist=randf_range(min_dist,max_dist)
	nextpivot=pivot+randf_range(PI/pivot_range_div/2,PI/pivot_range_div)*(randi_range(0,1)*2-1)
	var tempdist=nextdist
	var startpivot=nextpivot
	while true:
		var tempdestination=target.global_position+Vector2.RIGHT.rotated(nextpivot)*tempdist
		raytarget(tempdestination)
		if !ray.is_colliding():
			break
		tempdist=move_toward(tempdist,0.0,8)
		if tempdist==0:
			nextpivot+=PI/16
			tempdist=max_dist
			if angle_difference(nextpivot,startpivot)<0.1:
				reset_dest()
				return
	nextdist=tempdist
	while nextpivot>=2*PI:
		nextpivot-=2*PI
	if target.to_local(body.global_position).dot(Vector2.RIGHT.rotated(pivot))<0:
		reset_dest()

func raytarget(pos, start=body.global_position, inc_dashable=true):
	if !can_jump and inc_dashable:
		ray.set_collision_mask_value(18,true)
	else:
		ray.set_collision_mask_value(18,false)
	ray.global_position=start
	ray.target_position=pos-start
	ray.force_raycast_update()

func can_see_target():
	if !is_instance_valid(target):
		return false
	raytarget(target.global_position, body.global_position, false)
	return !ray.is_colliding()

func update_targetdist():
	targetdist=body.to_local(target.global_position).length()

func update():
	#circle
	dist_to_dest=body.to_local(destination).length()
	if (targetdist>max_dist+16 or (stay_away and targetdist<min_dist*.75) or dist_to_dest>96) and can_see_target():
		reset_dest()
	elif dist_to_dest<16 or (!can_see_target() and nextdist!=0) or (nextdist==0 and can_see_target()):
		next_dest()
	if pivot!=nextpivot:
		pivot=lerp_angle(pivot,nextpivot,.1)
	if dist!=nextdist:
		dist=move_toward(dist,nextdist,1)
	set_dest()
	raytarget(destination)
	if ray.is_colliding():
		nextdist-=(ray.get_collision_point()-destination).length()
	set_dest()
	direction=navigator.next_direction(destination)
