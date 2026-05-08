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
@onready var nav_agent=$Navigator.nav_agent

func _ready():
	super._ready()
	control.dont_notice=dont_notice
	started_falling.connect(control.death_throes)
	min_speed=max_speed-accel*8
	spawn=global_position
	if nav_agent.avoidance_enabled:
		nav_agent.velocity_computed.connect(nav_velocity_computed)

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

func nav_velocity_computed(new_velocity):
	if nav_agent.avoidance_enabled and !nav_agent.is_navigation_finished():
		var speed=velocity.length()
		velocity=new_velocity.normalized()*speed
