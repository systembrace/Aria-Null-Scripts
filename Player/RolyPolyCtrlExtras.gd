extends Node2D

@export var sprite: AnimatedSprite2D
@export var hurtbox: Hurtbox
@export var combo: Combo
@export var charge: Attack
var dh=0
var gravity=15
var disabled_hurtbox=false
var init_collision
var attacking=false
var bounces=0
@onready var body: Player=get_parent()

func _ready():
	body.collision.connect(bounce)
	await body.ready
	combo.started_attack.connect(disable_hurtbox)
	combo.ended_attack.connect(enable_hurtbox)
	combo.started_attack.connect(body.jump)
	combo.ended_attack.connect(body.land)
	init_collision=body.collision_mask
	body.set_collision_mask_value(9,false)
	hurtbox.hurtboxenabled.connect(set_collision)
	$DustTimer.timeout.connect($Dust.set.bind("emitting",false))
	charge.started_attack.connect(charge_started)
	charge.ended_attack.connect(charge_ended)

func charge_started():
	body.set_collision_mask_value(9,false)
	attacking=true
	$Ring1.emitting=true
	$Ring2.restart()
	$Dust.restart()
	$Dust.emitting=true
	bounces=0
	
func charge_ended():
	if !attacking:
		return
	body.set_collision_mask_value(9,true)
	attacking=false
	$DustTimer.start()
	$Ring1.restart()
	$Ring2.emitting=true
	bounces=0

func disable_hurtbox():
	if hurtbox.monitor:
		disabled_hurtbox=true
		hurtbox.disable_hurtbox()
		
func enable_hurtbox():
	if disabled_hurtbox:
		disabled_hurtbox=false
		hurtbox.enable_hurtbox()

func set_collision():
	body.collision_mask=init_collision
	hurtbox.hurtboxenabled.disconnect(set_collision)

func bounce(coll):
	if attacking:
		var new_vel=body.velocity.bounce(coll.get_normal())
		body.set_deferred("velocity",new_vel)
		charge.call_deferred("look_at",to_global(new_vel))
		return
	if body.velocity.length()<128:
		return
	$Bounce.play()
	body.set_deferred("velocity",body.velocity.bounce(coll.get_normal())/2)
	dh=min(3*body.velocity.length()/body.max_speed,3)
	if sprite.position.y!=0:
		dh*=(24-min(abs(sprite.position.y),32))/32

func _process(delta):
	if bounces>=10 or (body.control.attackpush==2 and body.velocity.length()*delta<body.max_speed*1.5*delta):
		if charge.damaging:
			charge.stop_attack()

func _physics_process(delta):
	sprite.position.y-=dh
	if int(sprite.position.y)<0:
		dh-=gravity*delta
	else:
		dh=0
		sprite.position.y=0
