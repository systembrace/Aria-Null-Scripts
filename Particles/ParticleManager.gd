extends Node2D

@export var hurtbox: Hurtbox
@export var combo: Combo
@export var charged=false
@export var parry=false
@export var animation: AnimationController
@export var dash: Dash
@export var partspawner:PartSpawner
@onready var body=get_parent()
var main
var sfx_swing
var sfx_dash
var sfx_hit
var sfx_parry
var sparks
var slash
var onhit
var sfx_charged
var chargedring
var onparry
var parryring
var footstep1
var sfx_footsteps
var footstep2
var dashtrail
var curr_step=1

func _ready():
	main=get_tree().get_root().get_node("Main")
	if hurtbox:
		sfx_hit=find_child("Hit")
		sparks=find_child("Sparks")
		slash=find_child("Slash")
		onhit=find_child("OnHit")
		onparry=find_child("OnParry")
		hurtbox.take_hit.connect(on_hit)
	if combo and charged:
		combo.fully_charged.connect(on_charged)
		chargedring=find_child("ChargedRing")
		sfx_charged=find_child("Charged")
	if combo and parry:
		sfx_parry=find_child("Parry")
		parryring=find_child("ParryRing")
		combo.parry.connect(on_parry)
	if animation:
		sfx_footsteps=find_child("Footsteps")
		footstep1=find_child("Footstep1")
		footstep2=find_child("Footstep1")
		animation.step.connect(on_step)
	if dash:
		sfx_dash=find_child("Dash")
		dashtrail=find_child("DashTrail")
		dash.dash_started.connect(on_dash)
	if find_child("Swing") and combo:
		sfx_swing=find_child("Swing")
		combo.started_attack.connect(on_attack)

func on_attack():
	sfx_swing.play()

func on_hit(attack, parried=false):
	if attack.damage==0:
		return
	if sfx_hit:
		var sfx=sfx_hit.duplicate()
		main.add_child(sfx)
		sfx.global_position=global_position
		sfx.finished.connect(sfx.queue_free)
		sfx.play()
	if sparks:
		sparks.restart()
		sparks.process_material.direction.x=Vector2.RIGHT.rotated(attack.global_rotation).x
		sparks.emitting=true
	if slash:
		slash.restart()
		slash.emitting=true
		slash.global_rotation=(-body.to_local(attack.global_position)).angle()
		#slash.position=Vector2.RIGHT.rotated(attack.global_rotation)*attack.knockback/32
	if onhit:
		onhit.restart()
		onhit.emitting=true
		onhit.global_rotation=randf_range(0,2*PI)
	if partspawner:
		partspawner.spawn(parried and attack.targetparent is Player,body.global_position,min(attack.damage,2))
	if onparry and parried:
		onparry.restart()
		onparry.emitting=true
		onparry.global_rotation=combo.current_attack.global_rotation

func on_charged():
	sfx_charged.play()
	var ring=chargedring.duplicate()
	main.add_child(ring)
	ring.global_position=chargedring.global_position
	ring.finished.connect(ring.queue_free)
	ring.emitting=true

func on_parry(_parried_by=false):
	sfx_parry.play()
	if parryring.emitting:
		return
	parryring.emitting=true
	parryring.position=combo.attack_vector()
	var ring=parryring.duplicate()
	main.add_child(ring)
	ring.modulate=Color.WHITE
	ring.global_position=parryring.global_position
	ring.finished.connect(ring.queue_free)
	ring.emitting=true

func on_step():
	sfx_footsteps.play()
	if curr_step==1:
		footstep2.restart()
		footstep1.process_material.direction=Vector3(-body.velocity.normalized().x,-.5,0)
		footstep1.emitting=true
		curr_step=2
	else:
		footstep1.restart()
		footstep2.process_material.direction=Vector3(-body.velocity.normalized().x,-.5,0)
		footstep2.emitting=true
		curr_step=1

func on_dash():
	sfx_dash.play()
	dashtrail.restart()
	dashtrail.position=-body.velocity/60
	dashtrail.process_material.direction=Vector3(body.velocity.x,body.velocity.y,0)
	dashtrail.emitting=true
