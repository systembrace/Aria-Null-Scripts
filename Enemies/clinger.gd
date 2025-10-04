extends Enemy
class_name Clinger

@export var on_wall_speed=50
@export var on_wall_accel=8
@export var off_wall_speed=96
@export var off_wall_accel=4
var on_wall=false
var launching=false
var on_corner=false
var wall_dir=Vector2.DOWN
var move_dir=1
var angle_to_target=0
var aim_pos_target=-wall_dir
var wall_area_prev=false
var edge_area_prev=false
var edge_area2_prev=false
@onready var hitstun=$Hitstun
@onready var ray=$WallFinder
@onready var wall_detector=$WallDetector
@onready var edge_area=$EdgeArea
@onready var edge_area2=$EdgeArea2
@onready var wall_area=$WallArea
@onready var gun=$Gun
@onready var ball=$Ball
@onready var aim_pos=$AimPos
@onready var climb_timer=$ClimbTimer

func _ready():
	super._ready()
	hitstun.stunned.connect($WallDetector/CollisionShape2D.set_deferred.bind("disabled",true))
	hitstun.recover.connect($WallDetector/CollisionShape2D.set_deferred.bind("disabled",false))
	$CollisionShape2D.shape=$CollisionShape2D.shape.duplicate()
	gun.equip(self)
	gun.updatesprite()
	await coyote.ready
	detach()
	attach()
	climb_timer.wait_time=0.1

func find_wall():
	for i in range(0,4):
		var test_dir=Vector2.RIGHT.rotated(i*PI/2)
		ray.target_position=test_dir*7
		ray.force_raycast_update()
		if ray.is_colliding():
			wall_dir=test_dir
			return
	wall_dir=Vector2.ZERO

func attach(_body=null):
	if on_wall or !wall_detector.has_overlapping_bodies():
		return
	find_wall()
	if wall_dir==Vector2.ZERO:
		return
	on_wall=true
	on_corner=false
	max_speed=on_wall_speed
	accel=on_wall_accel
	jump()
	$CollisionShape2D.shape.radius=5
	move_dir=randi_range(0,1)*2-1
	velocity=Vector2.ZERO
	update_rotation()
	control.force_transition("OnWallWander")

func detach(_body=null):
	if !on_wall or wall_detector.has_overlapping_bodies():
		return
	on_wall=false
	on_corner=false
	max_speed=off_wall_speed
	accel=off_wall_accel
	land()
	wall_detector.rotation=PI/4
	$CollisionShape2D.shape.radius=6

func update_rotation():
	edge_area.rotation=wall_dir.angle()-PI/2
	edge_area2.rotation=edge_area.rotation
	wall_area.rotation=edge_area.rotation
	wall_detector.rotation=edge_area.rotation+PI/4
	if move_dir!=0:
		$WallArea/CollisionShape2D.position.x=4*move_dir
		$EdgeArea/CollisionShape2D.position.x=4*move_dir
		$EdgeArea2/CollisionShape2D.position.x=-4*move_dir
		if on_corner:
			$EdgeArea2/CollisionShape2D.position.x+=move_dir*1.5
	if abs(wall_dir.x)>0.01 and !on_corner:
		ball.position=Vector2(-sign(wall_dir.x)*3,-9)
	elif wall_dir.y>0.01:
		ball.position=Vector2(0,-11)
	else:
		ball.position=Vector2(0,-8)
	if on_corner:
		ball.position.x=-sign(wall_dir.x)*1

func climb(dir=1):
	if !on_wall or (!climb_timer.is_stopped() and dir==1):
		return
	var turn=PI/4
	if dir==1:
		climb_timer.start()
		turn=PI/2
	wall_dir=Global.snap_vector_angle(wall_dir.rotated(-turn*move_dir*dir),turn)
	velocity=Global.snap_vector_angle(wall_dir.rotated(-PI/2*move_dir),PI/4)
	var rel_angle=snappedf(abs(wall_dir).angle(),PI/4)
	if dir==-1 and rel_angle<PI/2 and rel_angle>0:
		on_corner=true
	else:
		on_corner=false
	#$CollisionShape2D.rotation=wall_dir.angle()
	update_rotation()

func _process(delta):
	if on_wall and is_instance_valid(target):
		angle_to_target=(-wall_dir).angle_to(to_local(target.global_position-wall_dir*8))
	super._process(delta)
	#if on_wall and on_corner:
		#ray.target_position=wall_dir*8
		#ray.force_raycast_update()
		#if !ray.is_colliding():
			#climb(-1)
	if !on_wall:
		gun.always_show=false
		gun.hide_sprite()
		return
	elif !gun.always_show:
		gun.always_show=true
	
	if gun.force_alt_target or !is_instance_valid(target):
		aim_pos_target=-wall_dir*64
		if is_instance_valid(target):
			aim_pos_target=aim_pos_target.rotated(sign(angle_to_target)*PI/6)
	elif !gun.force_alt_target and is_instance_valid(target):
		aim_pos_target=gun.target_dir(gun.override_pos)*64
	var target_angle=aim_pos_target.angle()
	if abs(wall_dir.x)>0.01:
		if wall_dir.x>0:
			$AimPos/Pos.position.y=4
		else:
			$AimPos/Pos.position.y=-4
	else:
		$AimPos/Pos.position.y=0
	if aim_pos.rotation!=target_angle:
		var sgn=sign(angle_difference(aim_pos.rotation,target_angle))
		aim_pos.rotation+=PI/30*45*delta*sgn
		if sign(angle_difference(aim_pos.rotation,target_angle))!=sgn:
			aim_pos.rotation=target_angle
		gun.updatesprite()
	ball.animation=gun.sprite.animation
	ball.rotation=gun.sprite.rotation
	ball.flip_h=gun.sprite.flip_h
	ball.flip_v=gun.sprite.flip_v

func _physics_process(delta):
	if on_wall:
		gun.show()
		if !ball.visible:
			ball.show()
		if (edge_area_prev and !edge_area.has_overlapping_bodies()) or (on_corner and edge_area2_prev and !edge_area2.has_overlapping_bodies()):
			climb(-1)
		else:
			edge_area_prev=edge_area.has_overlapping_bodies()
			edge_area2_prev=edge_area.has_overlapping_bodies()
		if !wall_area_prev and wall_area.has_overlapping_bodies():
			climb()
		else:
			wall_area_prev=wall_area.has_overlapping_bodies()
	elif ball.visible:
		ball.hide()
		gun.hide()
	if wall_detector.has_overlapping_bodies():
		attach()
	else:
		detach()
	super._physics_process(delta)
	if on_corner:
		return
	var tempvel=velocity
	velocity=wall_dir*7
	move_and_slide()
	velocity=tempvel
