extends State
class_name EnemyDodge

@export var speed=180
@export var buffer=1.0
@export var dodge_dist=128
@export var combo: Combo
@export var hurtbox: Hurtbox
@export var searchfield: SearchField
@export var iframes=.12
@export var can_fall=false
var target: Node2D
var accel
var dashing=false
var go_to="attack"
@onready var timer=$Timer
@onready var iframes_timer=$Iframes

func _ready():
	timer.wait_time=buffer
	iframes_timer.wait_time=iframes
	iframes_timer.timeout.connect(hurtbox.enable_hurtbox)

func can_dodge():
	if body.target is Waypoint or !is_instance_valid(body.target.control.combo) or dashing:
		return false
	return timer.is_stopped() and combo.is_done_attacking() and ((body.target.control.combo.is_damaging() and body.to_local(body.target.global_position).length()<dodge_dist) or (searchfield and searchfield.nearby_count()>3))

func enter():
	timer.start()
	iframes_timer.start()
	accel=body.accel
	target=body.target
	if target is Waypoint:
		body.velocity=body.to_local(target.global_position).normalized()*280
		if body.can_jump:
			body.jump()
	else:
		body.velocity=target.to_local(body.global_position).normalized()*speed
		if body.can_jump and can_fall:
			body.jump()
	hurtbox.disable_hurtbox()
	dashing=true
	if find_child("SFX"):
		$SFX.play()

func update():
	if body.velocity.length()<=20:
		combo.enable_attack()
		if body.jumping:
			body.land()
		transition.emit(self,go_to)

func physics_update():
	body.velocity=body.velocity.move_toward(Vector2.ZERO,accel/2)

func exit():
	dashing=false
	if is_instance_valid(body.target) and body.target is Waypoint:
		body.target=null
	go_to="attack"
