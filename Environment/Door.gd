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
var closed_1=Vector2(-width/2.0,4)
var open_1=Vector2(-width,4)
var closed_2=Vector2(0,4)
var open_2=Vector2(width/2.0,4)

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
	
	if open_direction!="vertical":
		$PointLight2D.energy=0
		collision.rotation=PI/2
		clipping_check.rotation=PI/2
		$RigidBody2D.rotation=PI/2
		side1.texture=CanvasTexture.new()
		side1.texture.diffuse_texture=load("res://Assets/Art/environment/door_horizontal.png")
		side1.texture.normal_texture=load("res://Assets/Art/environment/door_horizontal_normal.png")
		side2.texture=side1.texture
		closed_1=Vector2(closed_1.y-height/2-4,closed_1.x+width/2)
		open_1=Vector2(open_1.y-height/2-4,open_1.x+width/2)
		closed_2=Vector2(closed_2.y-height/2-4,closed_2.x+width/2)
		open_2=Vector2(open_2.y-height/2-4,open_2.x+width/2)
	
	side1.position=closed_1
	side2.position=closed_2
	
	if opened:
		side1.position=open_1
		side2.position=open_2
		collision.set_deferred("disabled",true)
		opened=true
		$PointLight2D.visible=false
	
func snap_to_init(op):
	if op:
		side1.position=open_1
		side2.position=open_2
		collision.set_deferred("disabled",true)
		opened=true
		$PointLight2D.visible=false
	else:
		side1.position=closed_1
		side2.position=closed_2
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

func _process(delta):
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
		if side2.position==closed_2:
			state=""
			$PointLight2D.visible=true
			return
		side1.position=side1.position.move_toward(closed_1,speed*60*delta)
		side2.position=side2.position.move_toward(closed_2,speed*60*delta)
	elif state=="opening":
		if not opened and (side2.position-open_2).length()>(closed_2-open_2).length()*.375:
			opened=true
			clipping_check.monitoring=true
			collision.set_deferred("disabled",true)
		if side2.position==open_2:
			state=""
			return
		side1.position=side1.position.move_toward(open_1,speed*60*delta)
		side2.position=side2.position.move_toward(open_2,speed*60*delta)
