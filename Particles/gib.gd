extends Entity
class_name Gib

@onready var sprite=$AnimatedSprite2D
@onready var timer=$Timer
var h=1
var dh=0
var gravity=.5
var bounce=.5
var accel=24
var direction
var shrink=false
var step=0

func _ready():
	if !Global.can_create_particle():
		free()
		return
	Global.num_particles+=1
	super._ready()
	dh=randf_range(3,4)
	bounce=(dh-3)*.03+.1
	velocity=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*randf_range(48,96)
	sprite.frame=randi_range(0,sprite.sprite_frames.get_frame_count("default")-1)
	sprite.flip_h=randi_range(0,1)
	timer.wait_time=randf_range(7,15)
	timer.timeout.connect(startshrink)

func startshrink():
	shrink=true

func _process(delta):
	if abs(dh)>1 or h>2 or !on_floor:
		dh-=gravity*60*delta
		if h+dh<0 and on_floor:
			dh*=-1*bounce
		h+=dh*60*delta
	elif h!=0 and on_floor:
		h=move_toward(h,0,gravity*60*delta)
		dh=0
	if velocity!=Vector2.ZERO and on_floor and dh==0 and h<=0:
		velocity=velocity.move_toward(Vector2.ZERO,accel*60*delta)
	if not shrink and h==0 and timer.is_stopped() and on_floor and velocity==Vector2.ZERO:
		timer.start()
		sprite.position.y=0
		floor_checker.body_exited.disconnect(left_floor)
		floor_checker.queue_free()
		global_position=global_position.round()
	if shrink:
		step+=1*60*delta
		if step>=6:
			step=0
			sprite.scale=sprite.scale.move_toward(Vector2.ZERO,.25*60*delta)
			sprite.rotation=randf_range(0,2*PI)
	if sprite.scale.length()<=.1:
		Global.num_particles-=1
		queue_free()
	if not falling and not on_floor and h<=0:
		fall()
		shrink=true

func _physics_process(delta):
	super._physics_process(delta)
	if velocity!=Vector2.ZERO:
		var coll = move_and_collide(velocity*delta)
		if coll:
			velocity=velocity.bounce(coll.get_normal())/2
		sprite.position.y=-h
