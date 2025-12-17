extends Entity
class_name Enemy

@export var type = "enemy"
@export var max_speed: float
@export var accel: float
@export var target: Node2D
@export var chase_radius = 256
@export var scrap=5
signal death_throes
var min_speed=0
var spawn: Vector2
var ammo=60.0
var dont_notice=false
@onready var control=$AI

func _ready():
	super._ready()
	control.dont_notice=dont_notice
	started_falling.connect(control.death_throes)
	min_speed=max_speed-accel*8
	spawn=global_position

func _process(delta):
	if ammo<0.0:
		ammo=move_toward(ammo,0.0,5*delta)
		if ammo==0.0:
			ammo=60.0
	elif ammo<60.0:
		ammo=move_toward(ammo,60.0,5*delta)

func entity_physics_process(delta):
	super._physics_process(delta)

func _physics_process(delta):
	entity_physics_process(delta)
	move_and_slide()
