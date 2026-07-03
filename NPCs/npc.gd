extends Entity
class_name NPC

@export var max_speed: float
@export var accel: float
@export var actor=false
@export var can_speak_to=false
var main
var fall_anim=false
var gravity=6
var dh=0
@onready var anim_controller=$AnimationController

func _ready():
	super._ready()
	main=get_tree().get_root().get_node("Main")
	if actor:
		main.npcs[name]=self

func interact(_interacted=null):
	pass

func do_fall_anim(height=96):
	visible=true
	body_sprite.offset.y-=height
	anim_controller.cutscene_anim="falling"
	fall_anim=true

func _process(delta):
	if !fall_anim:
		return
	if body_sprite.offset.y<body_sprite_y_offset:
		dh+=gravity*60*delta
		body_sprite.offset.y=move_toward(body_sprite.offset.y,body_sprite_y_offset,dh*delta)
	else:
		dh=0
		fall_anim=false
		anim_controller.cutscene_anim="land"
		$Landed.emitting=true
		$Landing.play()
		$Footstep.play()
