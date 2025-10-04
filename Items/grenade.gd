extends Entity
class_name Grenade

var tossed=true
var maxdist=112
var mindist=44
var target=Vector2.ZERO
var speed=120
var dh=0.0
var gravity=6
var bonusdamage=0
@onready var sprite=$Sprite2D
@onready var trail=$Sprite2D/Trail
@onready var hitbox=$Hitbox
@onready var spritehitbox=$Sprite2D/SpriteHitbox

func _ready():
	super._ready()
	$SFX.play()
	sprite.position.y=-16
	trail.clear_points()
	trail.add_point(Vector2.ZERO)
	trail.add_point(Vector2.ZERO)
	spritehitbox.hit_something.connect(got_hit)
	if not tossed:
		speed*=4
		hitbox.area_entered.connect(bounce)
		gravity/=2
		$Destination.visible=false
		set_collision_mask_value(11,true)
		set_collision_mask_value(14,true)
	velocity=to_local(target).normalized()*speed
	if tossed:
		var time=clamp(mindist,to_local(target).length(),maxdist)/velocity.length()
		dh=time*gravity/2-16/time/60
		hitbox.set_collision_mask_value(2,false)
		hitbox.set_collision_mask_value(3,true)
		hitbox.got_parried.connect(parried)
	velocity=to_local(target).normalized()*speed
	target=global_position+velocity.normalized()*clamp(mindist,to_local(target).length(),maxdist)
	$Destination.global_position=target

func got_hit(area):
	if area.targetparent is Bullet and sprite.position.y>-30:
		$Bounce.play()
		Global.hitstop(.1,true)
		$Bounce.pitchlevel+=.2
		bonusdamage+=area.damage*2
		area.targetparent.hit()
		bounce()

func parried(area):
	if sprite.position.y<=-36:
		return
	bonusdamage+=area.damage*2
	$Bounce.play()
	Global.hitstop(.05,true)
	$Bounce.pitchlevel+=.2
	$Destination.visible=false
	if dh<0:
		dh=2
	velocity=velocity.length()*Vector2.RIGHT.rotated(area.rotation)

func bounce(_area=null):
	dh=2
	gravity=9
	velocity=Vector2.ZERO
	hitbox.set_collision_mask_value(2,false)

func explode():
	var main=get_tree().get_root().get_node("Main")
	var explosion=load("res://Scenes/General/explosion.tscn").instantiate()
	explosion.global_position=global_position
	explosion.damage=2+bonusdamage
	explosion.player_damage=1
	main.add_child(explosion)
	queue_free()

func _physics_process(delta):
	if not falling and not on_floor and sprite.position.y>=0:
		$Destination.visible=false
		fall()
	super._physics_process(delta)
	var prev=trail.global_position
	if sprite.position.y>=-1 and on_floor:
		sprite.position.y=-1
		velocity=Vector2.ZERO
		explode()
	else:
		sprite.rotation+=delta*30
		sprite.position.y-=dh*60*delta
		dh-=gravity*delta
	var coll = move_and_collide(velocity*delta)
	if coll:
		$HitWall.play()
		dh=0
		velocity=velocity.bounce(coll.get_normal())
		if not tossed:
			bounce()
	trail.remove_point(1)
	trail.add_point(trail.to_local(prev)*6)
	$Destination.global_position=target
