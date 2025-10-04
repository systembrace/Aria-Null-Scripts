extends CharacterBody2D
class_name Scrap

@onready var sprite=$Sprite
@onready var collect_area=$CollectArea
@onready var navigator=$Navigator
@onready var trail=$Sprite/Trail
var h=1
var dh=0
var gravity=.5
var bounce=.5
var collect=false
var player: Player
var speed=256
var accel=24
var direction
var step=0
var spindir=1

func _ready():
	dh=randf_range(3,7)
	bounce=(dh-3)*.04+.5
	velocity=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*randf_range(192,384)
	sprite.frame=randi_range(0,sprite.sprite_frames.get_frame_count("default")-1)
	trail.clear_points()
	trail.add_point(Vector2.ZERO)
	trail.add_point(Vector2.ZERO)
	$Smoke.emitting=true
	$Sparks.emitting=true

func _process(delta):
	step=int(step+1*60*delta)%8
	if not collect:
		if abs(dh)>1 or h>2:
			dh-=gravity*60*delta
			if h+dh<0:
				dh*=-1*bounce
				spindir*=-.9
			h+=dh*60*delta
			if step==0:
				sprite.rotation+=PI/6*spindir
		else:
			h=move_toward(h,0,gravity*60*delta)
			dh=0
			if h==0 and velocity.length()<.5 and not collect:
				if sprite.frame==0:
					sprite.rotation=PI*2/3*(randi_range(0,1)*2-1)
					sprite.offset.x+=1.5*sign(sprite.rotation)
				else:
					sprite.rotation=0
					sprite.flip_h=randi_range(0,1)
				collect=true
				direction=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*speed/2
		velocity=velocity.lerp(Vector2.ZERO,.1*60*delta)
	elif is_instance_valid(player):
		for area in collect_area.get_overlapping_bodies():
			if area is Player:
				area.control.collect_scrap()
				free()
				return
		direction=direction.move_toward(navigator.next_direction(player.global_position),accel*60*delta)
		velocity=velocity.move_toward(direction*speed,accel*60*delta)
	else:
		velocity=velocity.move_toward(Vector2.ZERO,accel*60*delta)
		player=get_parent().find_child("Player",true,false)

func _physics_process(_delta):
	var prev=trail.global_position
	move_and_slide()
	sprite.position.y=-h-4
	trail.remove_point(1)
	trail.add_point(trail.to_local(prev)*4)
