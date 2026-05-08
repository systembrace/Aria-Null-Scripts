@tool
extends AnimatedSprite2D
class_name Pseudo3DSprite

@export var dynamic_rotation=true
@export var flip=false
var num_sides=1
var num_anims=1
@onready var parent:Node2D=get_parent()

func _ready():
	num_anims=len(sprite_frames.get_animation_names())
	num_sides=num_anims
	if num_sides<4:
		num_sides*=2
	update()
	
func update():
	if !sprite_frames:
		return
	global_rotation=0
	var rot=parent.rotation
	while rot<0:
		rot+=2*PI
	animation=str(int(round(rot/PI/2*num_sides))%num_anims)
	if !flip:
		return
	if num_anims<num_sides and parent.rotation>=PI and parent.rotation<2*PI:
		flip_h=parent.rotation/PI/2*num_sides>num_sides/2
		flip_v=parent.rotation/PI/2*num_sides>=num_sides/2
	else:
		flip_h=false
		flip_v=false

func _process(_delta):
	if dynamic_rotation:
		pass#update()
