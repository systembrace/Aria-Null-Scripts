extends Node2D
class_name Rope

@export var weight=1.0
@export var stiffness=1.0
var curve
var wind=Vector2.ZERO
var point_out
var point_in
@onready var end=$End

func _ready():
	global_position+=Vector2(1,1)
	curve=Curve2D.new()
	curve.add_point(Vector2.ZERO)
	curve.add_point(Vector2.ZERO)
	if end.position.y>0:
		point_out=Vector2(end.position.x*.25,(end.position.y/2+20)*weight)
		point_in=Vector2(-end.position.x*.25,(end.position.y/2+20)*weight)
	else:
		point_out=Vector2(end.position.x*.25,(-end.position.y/2+20)*weight)
		point_in=Vector2(-end.position.x*.25,(-end.position.y/2+20)*weight)
	recalc()

func recalc():
	curve.set_point_position(1,end.position)
	curve.set_point_out(0,point_out+wind)
	curve.set_point_in(1,point_in+wind)

func _process(_delta):
	if Global.wind_dir==0:
		return
	wind=Vector2(5*Global.wind_dir,-5)+Vector2(cos(Global.wind_step)*10*Global.wind_speed+5*Global.wind_dir,sin(Global.wind_step)*1.25*Global.wind_speed)
	wind/=stiffness
	recalc()
	queue_redraw()

func _draw():
	var points=curve.tessellate_even_length(7,1)
	for point in points:
		draw_primitive([point],[Color.BLACK],[1.1])
		
