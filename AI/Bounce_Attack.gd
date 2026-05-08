extends State
class_name BounceAttack

@export var combo: Combo
var bounces=0
var in_state=false
@onready var particles=$GPUParticles2D

func enter():
	particles.emitting=true
	bounces=0
	if !body.bounced.is_connected(bounce):
		body.bounced.connect(bounce)
	in_state=true

func bounce():
	if !in_state:
		return
	bounces+=1
	Global.screenshake(.05)

func update():
	if !combo.is_attacking() or bounces>=10 or body.velocity.length()<body.max_speed*1.5:
		if combo.is_damaging():
			combo.enable_attack()
		transition.emit(self, "Follow")

func physics_update():
	body.velocity=body.velocity.move_toward(Vector2.ZERO,body.accel/2)

func exit():
	particles.emitting=false
	in_state=false
