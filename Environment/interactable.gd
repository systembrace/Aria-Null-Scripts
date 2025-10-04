extends Area2D
class_name Interactable

@export var can_interact=true
var near_interactor=false
@onready var sprite=$AnimatedSprite2D

func _ready():
	area_entered.connect(entered)
	area_exited.connect(exited)
	if can_interact:
		activate()
	else:
		deactivate()

func activate():
	can_interact=true
	if near_interactor:
		entered()

func deactivate():
	can_interact=false
	var temp=near_interactor
	exited()
	near_interactor=temp

func entered(_area=null):
	near_interactor=true
	if can_interact and sprite.material.get_shader_parameter("width")==0:
		sprite.material.set_shader_parameter("width",1)
		
func exited(_area=null):
	near_interactor=false
	if sprite.material.get_shader_parameter("width")==1:
		sprite.material.set_shader_parameter("width",0)
