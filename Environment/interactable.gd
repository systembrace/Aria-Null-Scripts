extends Area2D
class_name Interactable

@export var can_interact=true
signal interacted
var near_interactor=false
@onready var sprite=$AnimatedSprite2D

func _ready():
	area_entered.connect(entered_area)
	area_exited.connect(exited_area)
	if can_interact:
		activate()
	else:
		deactivate()

func interact(node):
	interacted.emit(node)

func activate():
	can_interact=true
	if near_interactor:
		entered_area()

func deactivate():
	can_interact=false
	var temp=near_interactor
	exited_area()
	near_interactor=temp

func entered_area(_area=null):
	near_interactor=true
	if can_interact and sprite.material.get_shader_parameter("width")==0:
		sprite.material.set_shader_parameter("width",1)
		
func exited_area(_area=null):
	near_interactor=false
	if sprite.material.get_shader_parameter("width")==1:
		sprite.material.set_shader_parameter("width",0)
