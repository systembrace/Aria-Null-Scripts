extends Node2D
class_name Scarf

var last:Node2D
var next:Node2D
var index=0
var x_offs=0
var y_offs=0
var damping=3
var sway_damping=2
var color="e51250"

func _ready():
	pass

func new_pos(gravity,sway=Vector2.ZERO,x=0,y=0):
	x_offs=x
	y_offs=y
	if last is ScarfStart:
		y_offs-=1
	position.x+=(last.position.x-position.x)/damping
	position.y+=(last.position.y-position.y+y+gravity)/damping
	position-=sway
	queue_redraw()
	if next!=null:
		next.new_pos(gravity,sway/sway_damping)
		
func _draw():
	draw_line(to_local(position)-Vector2(0,21),to_local(last.position)-Vector2(x_offs,21-y_offs),Color(color),1)
