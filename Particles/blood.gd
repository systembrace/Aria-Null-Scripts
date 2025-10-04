extends Entity
class_name Blood

@onready var sprite=$Sprite
@onready var trail=$Sprite/Trail
@onready var timer=$Timer
@onready var collect_area=$CollectArea
var h=1
var dh=0
var gravity=.15
var bounce=.5
var shrink=false
var parry=false
var collectable=false
var player: Player
var direction=Vector2.ZERO
var speed=256
var accel=24
var step=0

func _ready():
	if !parry and !Global.can_create_particle():
		free()
		return
	if !parry:
		Global.num_particles+=1
	super._ready()
	dh=randf_range(1,3)
	velocity+=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*randf_range(48,72)
	if parry:
		velocity*=4
		accel*=2
		speed*=1.5
	trail.clear_points()
	trail.add_point(Vector2.ZERO)
	trail.add_point(Vector2.ZERO)
	h=8
	timer.wait_time=randf_range(8,15)
	timer.timeout.connect(timerup)
	if randi()%2:
		sprite.flip_h=true
	if randi()%2:
		sprite.flip_v=true

func timerup():
	shrink=true
	collectable=true

func _process(delta):
	if parry:
		if not is_instance_valid(player):
			player=get_parent().find_child("Player",true,false)
			velocity=velocity.move_toward(Vector2.ZERO,accel*60*delta)
			direction=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*speed/2
			$CollisionShape2D.disabled=true
			timer.wait_time=.25
			timer.start()
		if is_instance_valid(player):
			if collectable:
				for area in collect_area.get_overlapping_bodies():
					if area is Player:
						area.control.rally()
						free()
						return
			direction=direction.move_toward(to_local(player.global_position).normalized(),accel*30*delta)
			velocity=velocity.move_toward(direction*speed,accel*60*delta)
		return
	if !$CollectArea/CollisionShape2D.disabled:
		$CollectArea/CollisionShape2D.disabled=true
	if h>0 or !on_floor:
		dh-=gravity*60*delta
		h+=dh*60*delta
	elif not shrink and h<0 and on_floor and timer.is_stopped():
		velocity=Vector2.ZERO
		dh=0
		h=0
		sprite.frame=randi_range(1,3)
		timer.start()
		$CollisionShape2D.disabled=true
		floor_checker.body_exited.disconnect(left_floor)
		floor_checker.queue_free()
		sprite.position.y=0
		global_position=global_position.round()
	if shrink:
		step+=1*60*delta
		if step>=8:
			step=0
			sprite.scale=sprite.scale.move_toward(Vector2.ZERO,.1*60*delta)
			sprite.rotation=randf_range(-PI/8,PI/8)
	if sprite.scale.length()<=.1:
		Global.num_particles-=1
		queue_free()
	if not falling and not on_floor and h<=0:
		fall()

func _physics_process(delta):
	super._physics_process(delta)
	if velocity!=Vector2.ZERO:
		var prev=trail.global_position
		move_and_slide()
		sprite.position.y=-h
		trail.points[1]=trail.to_local(prev)*4/(60*delta)
	elif trail.points[1]!=trail.points[0]:
		trail.points[1]=trail.points[0]
