extends CharacterBody2D
class_name Harpoon

var max_speed=768
var speed=max_speed
var dir=Vector2.RIGHT
var stuck=false
var retracting=false
var enemy=null
var stuck_in_enemy=false
var tether_length=0
var tether=null
var tetherdir
var collider_moved=false
var shrink=false
var step=0
var previous_enemy=null
@onready var sprite=$Mask
@onready var hitbox=$Hitbox
@onready var collider=$CollisionShape2D
@onready var timer=$Timer
@onready var charge_timer=$ChargeTimer


func _ready():
	sprite.rotation=dir.angle()
	sprite.flip_v=randi_range(0,1)
	velocity=dir*speed
	tetherdir=dir
	hitbox.hit_hurtbox.connect(hit)
	hitbox.got_parried.connect(deflect)
	hitbox.global_position=sprite.global_position-dir*16
	collider.shape=collider.shape.duplicate()
	timer.wait_time=5
	timer.timeout.connect(set.bind("shrink",true))
	charge_timer.wait_time=0.5
	$FreeTimer.wait_time=20
	$FreeTimer.timeout.connect(queue_free)
	$FreeTimer.start()

func make_tether():
	var main=get_tree().get_root().get_node("Main")
	tether=Node2D.new()
	tether.set_script(ScarfStart)
	tether.parent=self
	tether.global_position=round(global_position+Vector2.UP)
	tether.length=4
	tether.damping=4
	tether.sway_damping=.75
	tether.next_dir=-dir*tether_length/8
	tether.offset=-dir*14+Vector2.DOWN*5
	tether.color="8b8e91"
	main.call_deferred("add_child",tether)
	$ReelSnap.play()

func hit(object=null):
	$Slash.rotation=sprite.rotation
	$Slash.emitting=true
	if retracting:
		return
	if is_instance_valid(object) and object.grappleable:
		if object==previous_enemy:
			return
		if !"control" in object or object.control.health.hp>hitbox.damage:
			enemy=object
			enemy.call_deferred("add_status_effect",self)
			stuck_in_enemy=true
			collider.set_deferred("disabled",true)
			$Mask/End.play("active")
			if $Mask/Tip.global_position.y>$Mask/End.global_position.y:
				$Mask/End.y_sort_enabled=true
				$Mask/Tip.z_index=1
			else:
				$Mask/Tip.y_sort_enabled=true
				$Mask/End.z_index=1
			global_position=enemy.global_position-Vector2.UP*7
			$FreeTimer.stop()
		else:
			return
	velocity=Vector2.ZERO
	stuck=true
	if !stuck_in_enemy:
		$FreeTimer.start()
		sprite.texture=load("res://assets/Art/guns/harpoon/harpoon_mask.png")
		sprite.clip_children=CLIP_CHILDREN_ONLY
		timer.start()
		$HitWall.play()
		$CustomParticleSpawner.spawn(false, collider.global_position-dir*4)
		if !tether:
			make_tether()
	hitbox.disable_hitbox()
	collider.shape.size.x=32
	global_position=round(global_position)

func deflect(attack,charged=false):
	visible=true
	if !charged and !stuck_in_enemy:
		return
	stuck=false
	collider.set_deferred("disabled",false)
	retracting=false
	collider_moved=false
	dir=attack.targetparent.to_local(attack.target.global_position)
	dir=dir.normalized()
	speed=max_speed
	hitbox.call_deferred("enable_hitbox")
	hitbox.position=Vector2.UP*19
	$Slash.rotation=sprite.rotation
	$Slash.emitting=true
	hitbox.damage=min(hitbox.damage+0.5,5)
	if stuck_in_enemy:
		stuck_in_enemy=false
		previous_enemy=enemy
		enemy.remove_status_effect(self)
		enemy=null
		$Mask/End.animation="default"
		$Mask/End.z_index=0
		$Mask/Tip.z_index=0
		$Mask/End.y_sort_enabled=false
		$Mask/Tip.y_sort_enabled=false
		collider.shape.size.x=10
	$Deflect.pitchlevel=min(0.92+0.091*(hitbox.damage-1.5)/0.5,1.56)
	$Deflect.play()
	Global.hitstop(.15)

func hit_enemy(attack=null, _parry=false):
	if !stuck_in_enemy or attack.targetparent is Harpoon:
		return
	enemy.control.health.take_damage(hitbox,false)
	$Mask/End.play("hit")
	var sfx=$Activate.duplicate()
	get_tree().get_root().get_node("Main").add_child(sfx)
	sfx.global_position=$Activate.global_position
	sfx.play()
	if attack is ChargedAttack and attack.charged and charge_timer.is_stopped():
		charge_timer.start()
		deflect(attack,true)

func retract():
	stuck=false
	retracting=true
	speed*=.75
	collider.set_deferred("disabled",true)
	hitbox.set_collision_mask_value(2,false)
	hitbox.enable_hitbox()
	if is_instance_valid(enemy):
		if enemy.control.hitstun.posture_threshold<3:
			enemy.control.hitstun.stun()
		enemy.velocity=velocity/2
		enemy.jump()

func _process(delta):
	if stuck_in_enemy and $Mask/End.animation=="hit" and !$Mask/End.is_playing():
		$Mask/End.play("active")
	if sprite.scale.x<=.1:
		queue_free()
		return
	if shrink:
		if is_instance_valid(tether):
			tether.queue_free()
		step+=1*60*delta
		if step>=6:
			step=0
			sprite.scale.x=move_toward(sprite.scale.x,0,.25*60*delta)
			$Shadow.scale.x=sprite.scale.x
		return
	if stuck:
		if is_instance_valid(enemy):
			global_position=enemy.global_position-Vector2.UP*7
		elif stuck_in_enemy:
			stuck_in_enemy=false
			enemy=null
			retract()
		return
	velocity=dir*speed
	sprite.rotation=dir.angle()
	if retracting:
		sprite.rotation+=PI
	$Shadow.rotation=sprite.rotation

func _physics_process(delta):
	collider.rotation=sprite.rotation
	collider.global_position=hitbox.global_position
	if !collider_moved:
		collider.position.y=0
	var coll=move_and_collide(velocity*delta,stuck and not stuck_in_enemy)
	if hitbox.position!=sprite.position and not retracting:
		hitbox.position=hitbox.position.move_toward(sprite.position,8*delta*60)
	
	if !coll and stuck and not stuck_in_enemy:
		retract()
	elif coll and not (stuck and not stuck_in_enemy):
		if coll.get_normal().y<=0 and collider.position.y==0:
			collider.position.y=-19
			collider_moved=true
			z_index=-1
			return
		hit(null)
		if coll.get_normal()==Vector2.DOWN:
			var main=get_tree().get_root().get_node("Main")
			var decal = load("res://Scenes/Particles/decal.tscn").instantiate()
			decal.crack=true
			decal.global_position=sprite.global_position+Vector2.DOWN*22+dir*3
			main.add_child(decal)
		return
