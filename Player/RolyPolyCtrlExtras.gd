extends Node2D

@export var sprite: AnimatedSprite2D
@export var hurtbox: Hurtbox
@export var combo: Combo
var dh=0
var gravity=15
var disabled_hurtbox=false
var init_collision
@onready var body: Player=get_parent()

func _ready():
	body.collision.connect(bounce)
	await body.ready
	body.control.combo.started_attack.connect(disable_hurtbox)
	body.control.combo.ended_attack.connect(enable_hurtbox)
	combo.started_attack.connect(body.jump)
	combo.ended_attack.connect(body.land)
	init_collision=body.collision_mask
	body.set_collision_mask_value(9,false)
	hurtbox.hurtboxenabled.connect(set_collision)

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
	if body.velocity.length()<128:
		return
	$Bounce.play()
	body.set_deferred("velocity",body.velocity.bounce(coll.get_normal())/2)
	dh=min(3*body.velocity.length()/body.max_speed,3)
	if sprite.position.y!=0:
		dh*=(24-min(abs(sprite.position.y),32))/32
	
func _physics_process(delta):
	sprite.position.y-=dh
	if int(sprite.position.y)<0:
		dh-=gravity*delta
	else:
		dh=0
		sprite.position.y=0
