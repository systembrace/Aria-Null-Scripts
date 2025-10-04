extends Node2D
class_name ScarfStart

@export var length=6
@export var parent:Node2D
var animation:AnimationController
var next_dir=Vector2.ZERO
var color="e51250"
var offset=Vector2.ZERO
var damping=3
var sway_damping=2
var next:Scarf
var time=0

func _ready():
	if not parent or not is_instance_valid(parent):
		free()
		return
	if "fell" in parent:
		parent.fell.connect(queue_free)
	var prev=self
	global_position=parent.global_position+Vector2.UP+offset
	for i in range(0,length):
		var new=Scarf.new()
		new.last=prev
		prev.next=new
		new.index=length-i+1
		new.position=global_position+next_dir
		new.color=color
		new.damping=damping
		new.sway_damping=sway_damping
		next_dir+=next_dir
		add_child(new)
		prev=new
	animation=parent.find_child("AnimationController")

func _process(delta):
	if not parent or not is_instance_valid(parent):
		free()
		return
	if "min_speed" in parent:
		time+=delta*2*PI*parent.velocity.length()/(parent.min_speed+parent.accel)
	else:
		time+=delta*2*PI
	if time>2*PI:
		time-=2*PI
	var x=0
	var y=0
	var gravity=3/(parent.velocity.length()+1)
	var sway=Vector2.ZERO
	if "tetherdir" in parent:
		sway=-parent.tetherdir
		if parent.velocity.length()==0:
			parent.tetherdir*=.9
		if parent.tetherdir.length()<.05:
			parent.tetherdir=Vector2.ZERO
	if "min_speed" in parent:
		sway=parent.velocity.rotated(sin(time)*PI/8)/parent.min_speed
	global_position=parent.global_position+Vector2.UP+offset
	if animation:
		if abs(animation.direction.y)>abs(animation.direction.x):
			if animation.direction.y<0:
				global_position-=Vector2.UP
				if animation.anim=="attack":
					y-=1
		else:
			if animation.direction.x<0:
				x+=2
			if animation.direction.x>0:
				x-=2
		if animation.anim=="run":
			y+=3
		elif animation.direction.y<0:
				y+=2
	if "falling" in parent and parent.falling:
		y+=parent.body_sprite.offset.y-parent.body_sprite_y_offset
		z_index-=60*delta
	next.new_pos(gravity,sway,x,y)
