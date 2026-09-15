@tool
extends Node2D
class_name Rope

@export var weight=1.0
@export var stiffness=1.0
@export var background=false
@export var height=20
@export var end_height=20
@export var points=7
@export var color:Color=Color.BLACK
var curve: Curve2D
var wind=Vector2.ZERO
var point_out
var point_in
@onready var end=$End

func _ready():
	if background:
		z_index=2
	curve=Curve2D.new()
	curve.add_point(Vector2.ZERO)
	curve.add_point(Vector2.ZERO)
	if end.position.y>0:
		point_out=Vector2(end.position.x*.25,(end.position.y/2+end_height)*weight)
		point_in=Vector2(-end.position.x*.25,(end.position.y/2+height)*weight)
	else:
		point_out=Vector2(end.position.x*.25,(-end.position.y/2+end_height)*weight)
		point_in=Vector2(-end.position.x*.25,(-end.position.y/2+height)*weight)
	recalc()

func recalc():
	curve.set_point_position(1,end.position)
	curve.set_point_out(0,point_out+wind)
	curve.set_point_in(1,point_in+wind)

func _process(_delta):
	if Engine.is_editor_hint():
		return
	if Global.wind_dir==0:
		return
	wind=Vector2(5*Global.wind_dir,-5)+Vector2(cos(Global.wind_step)*10*Global.wind_speed+5*Global.wind_dir,sin(Global.wind_step)*1.25*Global.wind_speed)
	wind/=stiffness
	recalc()
	queue_redraw()

func _draw():
	var real_points=curve.tessellate_even_length(points,1)
	var temp_color=color
	if Engine.is_editor_hint():
		temp_color=Color.WHITE
	for point in real_points:
		draw_primitive([point],[temp_color],[1.1])
