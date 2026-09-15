extends Node2D

@export var sprite: AnimatedSprite2D
@export var hurtbox: Hurtbox
@export var combo: Combo
@export var charge: Attack
@export var attack: Attack
var dh=0
var gravity=10
var disabled_hurtbox=false
var init_collision
var charging=false
var bounces=0
@onready var body: Player=get_parent()
@onready var jump_timer=get_parent().find_child("JumpTimer")

func _ready():
	body.collision.connect(bounce)
	await body.ready
	combo.started_attack.connect(disable_hurtbox)
	combo.ended_attack.connect(enable_hurtbox)
	attack.started_attack.connect(jump)
	jump_timer.timeout.connect(land)
	init_collision=body.collision_mask
	body.set_collision_mask_value(9,false)
	hurtbox.hurtboxenabled.connect(set_collision)
	$DustTimer.timeout.connect($Dust.set.bind("emitting",false))
	charge.started_attack.connect(charge_started)
	charge.ended_attack.connect(charge_ended)

func charge_started():
	jump(.25)
	body.set_collision_mask_value(9,false)
	charging=true
	$Ring1.emitting=true
	$Ring2.restart()
	$Dust.restart()
	$Dust.emitting=true
	bounces=0
	
func charge_ended():
	if !charging:
		return
	body.set_collision_mask_value(9,true)
	charging=false
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

func jump(time=.45):
	jump_timer.wait_time=time
	body.jump()
	jump_timer.start()

func land():
	if !body.on_floor:
		body.set_collision_mask_value(19,true)
	body.land()

func bounce(coll:KinematicCollision2D):
	if charging:
		var new_vel=body.velocity.bounce(coll.get_normal())
		body.set_deferred("velocity",new_vel)
		charge.call_deferred("look_at",to_global(new_vel))
		return
	if body.velocity.length()<128:
		return
	$Bounce.play()
	body.set_deferred("velocity",body.velocity.bounce(coll.get_normal())/2)
	dh=min(2*body.velocity.length()/body.max_speed,2)
	if body.height!=0:
		dh*=(24-min(abs(body.height),32))/32

func _process(delta):
	if bounces>=10 or (body.control.attackpush==2 and body.velocity.length()*delta<body.max_speed*1.5*delta):
		if charge.damaging:
			charge.stop_attack()
	if !charge.attacking:
		return
	if $Dust.emitting and !body.on_floor:
		$Dust.emitting=false
	elif !$Dust.emitting and body.on_floor and !body.falling:
		$Dust.emitting=true

func _physics_process(delta):
	body.height+=dh
	if int(body.height)<=0 and ((combo.is_damaging() and !charge.damaging) or body.on_floor):
		dh=0
		body.height=0
	else:
		dh-=gravity*delta
