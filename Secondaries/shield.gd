extends Secondary
class_name Shield

signal take_hit
signal parry
signal deactivated
var active=false
var durability=60.0
var attack=null
var enemy=null
var shake=0
@onready var hurtbox:Hurtbox=$Hurtbox
@onready var bounce:Attack=$Bounce
@onready var hitbox:Attack=$Hitbox
@onready var coll:CollisionShape2D=$CollisionShape2D
@onready var timer=$Timer
@onready var front=$Front
@onready var back=$Front/Back
@onready var cracks=$Front/Cracks
@onready var attack_sprite=$AttackSprite
@onready var flash_anim=$Front/Flash

func _ready():
	hurtbox.take_hit.connect(absorb)
	hurtbox.disable_hurtbox()
	coll.set_deferred("disabled",true)
	#timer.wait_time=0.16
	#timer.timeout.connect(buffer)
	front.visible=false

func equip(node):
	super.equip(node)
	front.visible=false

func activate():
	if active:
		return
	front.animation="default"
	back.animation="default"
	front.play()
	back.play()
	make_cracks()
	active=true
	cant_move=true
	hurtbox.enable_hurtbox()
	front.visible=true
	coll.set_deferred("disabled",false)
	$Activate.play()

func make_cracks():
	if durability>0:
		if durability<29:
			cracks.frame=2
			return
		elif durability<49:
			cracks.frame=1
			return
	cracks.frame=0

func absorb(node):
	#if not node.targetparent is Bullet:
	#	attack=node
	#timer.start()
	flash_anim.stop()
	flash_anim.play("hitflash")
	bounce.look_at(node.global_position)
	bounce.attack()
	take_hit.emit()
	durability-=60.0/numshots
	shake=2/(durability*numshots/60.0)
	if floor(durability*numshots/60.0)<1:
		durability=0
		targetparent.control.hitstun.stun()
		deactivate()
	elif durability<29:
		$Absorb2.play()
	else:
		$Absorb1.play()
	make_cracks()

func buffer():
	attack=null
	if durability==0:
		targetparent.control.hitstun.stun()
		deactivate()
	
func deactivate():
	if !active:
		return
	active=false
	cant_move=false
	hurtbox.disable_hurtbox()
	coll.set_deferred("disabled",true)
	deactivated.emit()
	shake=0
	#if attack:
	#	hitbox.damage=attack.damage
	#	hitbox.global_position=attack.targetparent.global_position
	#	hitbox.look_at(global_position)
	#	hitbox.rotation+=PI
	#	hitbox.attack()
	#	bounce.attack()
	#	parry.emit(null,true)
	#	enemy=attack.targetparent
	#	attack_sprite.visible=true
	#	attack_sprite.scale=Vector2(1,1)
	#	durability=min(durability+60.0/numshots,60.0)
	#	Global.call_deferred("hitstop",0.15)
	#	attack=null
	#	timer.stop()
	if durability!=0:
		front.visible=false
		$Deactivate.play()
	else:
		Global.hitstop(0.15)
		$OnBreak.emitting=true
		front.animation="break"
		back.animation="break"
		front.play()
		back.play()
		$Break.play()

func _process(delta):
	#if attack_sprite.visible and attack_sprite.scale!=Vector2.ZERO:
	#	if is_instance_valid(enemy):
	#		attack_sprite.global_position=enemy.global_position
	#	attack_sprite.scale=attack_sprite.scale.move_toward(Vector2.ZERO,0.1*delta*60)
	#elif attack_sprite.visible:
	#	attack_sprite.visible=false
	if shake!=0:
		front.position=Vector2(0,2)+Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*shake
		shake=lerpf(shake,0.0,0.25*delta*60)
	elif front.position!=Vector2(0,2):
		front.position=Vector2(0,2)
