extends Entity
class_name Ally

@export var max_speed: float
@export var accel: float
@export var target: Node2D
@export var can_speak_to=false
var main
var min_speed
var ammo=60.0
@onready var control=$AI

func _ready():
	min_speed=max_speed/2
	main=get_tree().get_root().get_node("Main")
	super._ready()

func interact(_interacted=null):
	pass

func _process(delta):
	if main.dark and !$Lamp.enabled:
		$Lamp.enabled=true
	elif !main.dark and $Lamp.enabled:
		$Lamp.enabled=false
	if ammo<0.0:
		ammo=move_toward(ammo,0.0,5*delta)
		if ammo==0.0:
			ammo=60.0
	elif ammo<60.0:
		ammo=move_toward(ammo,60.0,5*delta)

func _physics_process(delta):
	super._physics_process(delta)
	#var coll = move_and_collide(velocity*delta,true)
	#if coll:
	#	collision.emit(coll)
	move_and_slide()
	if velocity.length()<.5:
		global_position=global_position.round()
