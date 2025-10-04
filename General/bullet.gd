extends CharacterBody2D
class_name Bullet

var faction="enemy"
var speed=384
var damage=1
var size=1.0
var knockback=100
var dir=Vector2.UP
var main
var collider_moved=false
@onready var sprite=$AnimatedSprite2D
@onready var hitbox=$Hitbox
@onready var collider=$CollisionShape2D

func _ready():
	change_faction()
	main=get_tree().get_root().get_node("Main")
	if main.dark:
		$AnimatedSprite2D/Light.enabled=true
		$AnimatedSprite2D/Light.energy=size
	hitbox.got_parried.connect(deflect)
	hitbox.hit_hurtbox.connect(hit.unbind(1))
	hitbox.hitbox.shape=CapsuleShape2D.new()
	hitbox.hitbox.shape.radius=6
	hitbox.hitbox.shape.radius*=size
	hitbox.hitbox.shape.height=28
	hitbox.hitbox.shape.height-=8-8*size
	hitbox.hitbox.position.y=6
	hitbox.damage=damage
	hitbox.global_position=sprite.global_position-dir*16
	hitbox.knockback=knockback
	sprite.frame=size*2-1
	velocity=dir*speed
	$FreeTimer.wait_time=20
	$FreeTimer.timeout.connect(queue_free)
	$FreeTimer.start()
	$Trail.points[1]=-dir*12

func change_faction():
	var gradient=$Sparks.process_material.color_ramp.gradient
	if faction=="player":
		sprite.animation="player"
		$Trail.default_color="87b3ff"
		gradient.set_color(1,"87b3ff")
		gradient.set_color(2,"5975ff")
		hitbox.set_collision_mask_value(1,false)
		hitbox.set_collision_mask_value(2,true)
		$AnimatedSprite2D/Light.color="87b3ff"
	else:
		sprite.animation="enemy"
		$Trail.default_color="e51250"
		gradient.set_color(1,"f23084")
		gradient.set_color(2,"e51250")
		hitbox.set_collision_mask_value(2,false)
		hitbox.set_collision_mask_value(1,true)
		$AnimatedSprite2D/Light.color="f15699"
	sprite.frame=size*2-1

func deflect(area):
	Global.hitstop(.15)
	if faction=="player":
		if not area.targetparent is Player and not area.targetparent is Ally:
			faction="enemy"
			hitbox.damage=1
			var sfx=$Deflect.duplicate()
			sfx.global_position=global_position
			sfx.finished.connect(sfx.queue_free)
			main.add_child(sfx)
			sfx.play()
		else:
			faction="player"
			hitbox.damage*=2
			area.parry.emit(self)
	else:
		area.parry.emit()
		if area.targetparent is Player or area.targetparent is Ally:
			$BloodSpawner.spawn(true)
			faction="player"
			hitbox.damage*=2
		else:
			damage=1
	if faction=="player":
		speed=max(speed*2,384*1.5)
	change_faction()
	dir=to_local(area.target.global_position)
	if area.target is Mouse:
		dir+=Vector2.DOWN*16
	dir=dir.normalized()
	$Trail.points[1]=-dir*12
	var sparks=$Sparks.duplicate()
	main.add_child(sparks)
	sparks.global_position=global_position+Vector2.UP*19+dir*4
	sparks.process_material=sparks.process_material.duplicate()
	sparks.process_material.spread=180
	sparks.amount*=2
	sparks.process_material.initial_velocity_max*=.85
	sparks.process_material.initial_velocity_min*=.85
	sparks.z_index=1
	sparks.process_material.direction.x=0
	sparks.finished.connect(sparks.queue_free)
	sparks.emitting=true

func _process(_delta):
	if velocity!=dir*speed:
		velocity=dir*speed

func hit(coll=null):
	var sparks = $Sparks.duplicate()
	var light=find_child("Light")
	if light and main.dark:
		light.energy=.5
		$AnimatedSprite2D.remove_child(light)
		sparks.add_child(light)
	main.add_child(sparks)
	sparks.global_position=sprite.global_position+Vector2.RIGHT*dir.normalized().x
	sparks.process_material=sparks.process_material.duplicate()
	if coll:
		sparks.process_material.direction.x=-dir.normalized().x
		if coll.get_normal().y<=0:
			if coll.get_normal().y<0:
				sparks.global_position+=Vector2.DOWN*3
			sparks.process_material.direction.y=-dir.normalized().y
		else:
			sparks.amount*=2
			sparks.process_material.spread=180
			sparks.process_material.initial_velocity_max*=.7
			sparks.process_material.initial_velocity_min*=.7
			sparks.z_index=1
			sparks.process_material.direction.x=0
	else:
		sparks.process_material.direction=Vector3(-dir.x,-dir.y,0)
	sparks.finished.connect(sparks.queue_free)
	sparks.emitting=true
	queue_free()

func hit_wall(coll):
	var hitwall=$HitWall.duplicate()
	main.add_child(hitwall)
	hitwall.global_position=global_position
	hitwall.finished.connect(hitwall.queue_free)
	hitwall.play()
	$PartSpawner.spawn(false,collider.global_position-dir*4)
	if coll.get_normal()==Vector2.DOWN:
		var decal = load("res://Scenes/Particles/decal.tscn").instantiate()
		main.add_child(decal)
		decal.global_position=sprite.global_position+Vector2.DOWN*16
	hit(coll)

func _physics_process(delta):
	#sprite.rotation+=.1
	collider.global_position=hitbox.global_position
	if !collider_moved:
		collider.position.y+=19
	var coll=move_and_collide(velocity*delta)
	if hitbox.position!=sprite.position:
		hitbox.position=hitbox.position.move_toward(sprite.position,8*delta*60)
	if coll:
		if coll.get_normal().y<=0 and !collider_moved:
			collider_moved=true
			z_index=-1
			sprite.z_index=-1
			return
		hit_wall(coll)
