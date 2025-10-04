extends CharacterBody2D
class_name Door

@export var open_direction = "vertical"
@export var width=32
@export var height=8
@export var sprite_height=56
@export var opened=false
@export var speed=.25
@export var open_area: Area2D
@export var close_area: Area2D
@export var toggle_area: Area2D
@onready var collision=$CollisionShape2D
@onready var clipping_check=$ClippingCheck
@onready var side1=$Side1
@onready var side2=$Side2
var state=""

func _ready():
	if get_parent() is Main and get_parent().dark:
		$PointLight2D.energy=1.5
		$PointLight2D.color="ffe6bf"
	collision.shape.size.x=width
	collision.shape.size.y=height
	clipping_check.find_child("CollisionShape2D").shape = collision.shape
	
	if open_area:
		open_area.body_entered.connect(open)
		open_area.area_entered.connect(open)
	if close_area:
		close_area.body_exited.connect(close)
		close_area.area_exited.connect(close)
	if toggle_area:
		toggle_area.body_entered.connect(open)
		toggle_area.body_exited.connect(close)
		toggle_area.area_entered.connect(open)
		toggle_area.area_exited.connect(close)
	
	side1.position.x=-width/2.0
	side1.position.y=0
	side2.position.x=0
	side2.position.y=0
	
	if opened:
		side1.position.x=-width
		side2.position.x=width/2.0
		collision.set_deferred("disabled",true)
		opened=true
		$PointLight2D.visible=false
	
	if open_direction!="vertical":
		side2.flip_h=false
	
func snap_to_init(op):
	if op:
		side1.position.x=-width
		side2.position.x=width/2.0
		collision.set_deferred("disabled",true)
		opened=true
		$PointLight2D.visible=false
	else:
		side1.position.x=-width/2.0
		side2.position.x=0
		collision.set_deferred("disabled",false)
		opened=false
		$PointLight2D.visible=true
	
func close(_body=null):
	if opened:
		state="closing"
	
func open(_body=null):
	if not opened:
		state="opening"
		$PointLight2D.visible=false

func _process(_delta):
	if state!="":
		$Side1/Dust.emitting=true
		$Side2/Dust.emitting=true
		$Move.play()
	elif $Side1/Dust.emitting:
		$Move.stop()
		$Stop.play()
		$Side1/StopDust.emitting=true
		$Side2/StopDust.emitting=true
		$Side1/Dust.emitting=false
		$Side2/Dust.emitting=false
	if state=="closing" and (!clipping_check.monitoring or not clipping_check.has_overlapping_bodies()):
		if opened:
			opened=false
			collision.set_deferred("disabled",false)
			clipping_check.monitoring=false
		if open_direction=="vertical":
			if side2.position.x==0:
				state=""
				$PointLight2D.visible=true
				return
			side1.position.x=move_toward(side1.position.x,-width/2.0,speed)
			side2.position.x=move_toward(side2.position.x,0,speed)
	elif state=="opening":
		if open_direction=="vertical":
			if not opened and side2.position.x>6:
				opened=true
				clipping_check.monitoring=true
				collision.set_deferred("disabled",true)
			if side2.position.x==width/2.0:
				state=""
				return
			side1.position.x=move_toward(side1.position.x,-width,speed)
			side2.position.x=move_toward(side2.position.x,width/2.0,speed)
