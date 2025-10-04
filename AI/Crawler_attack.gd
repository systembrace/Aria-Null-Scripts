extends RangedState
class_name CrawlerAttack

var move_range=PI/8
var stop_range=PI/24
var corner_range=PI/4

func _ready():
	super._ready()
	move_range+=randf_range(-PI/45,PI/45)
	stop_range+=randf_range(-PI/45,PI/45)

func enter():
	if !is_instance_valid(body.target):
		transition.emit("OnWallWander")
		return
	target=body.target
	speed=body.max_speed
	accel=body.accel
	gun=body.gun

func update():
	if !body.on_wall or !is_instance_valid(body.target):
		transition.emit(self,"Wander")
		return
	if target!=body.target:
		target=body.target
	var angle_to_target=body.angle_to_target
	var temp_dir=body.move_dir
	var temp_move_range=move_range
	var temp_stop_range=stop_range
	if body.on_corner:
		temp_move_range*=2
		temp_stop_range*=6
	if can_see_target():
		if abs(angle_to_target)>temp_move_range:
			body.move_dir=sign(angle_to_target)
		elif abs(angle_to_target)<temp_stop_range and can_see_target():
			body.move_dir=0
	elif body.move_dir==0:
		body.move_dir=randi_range(0,1)*2-1
	if temp_dir!=body.move_dir:
		body.update_rotation()
	
	if can_see_target() and abs(angle_to_target)<=PI/6:
		gun.force_alt_target=false
		update_targetdist()
		try_shoot()
	else:
		gun.force_alt_target=true
		delay.stop()
	
	if body.move_dir!=0:
		direction=body.wall_dir.rotated(-PI/2*body.move_dir)
	else:
		direction=Vector2.ZERO

func exit():
	pass
