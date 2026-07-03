extends NPC
class_name Ally

@export var target: Node2D
@export var tessa=false
var min_speed
var ammo=60.0
var kneeling=false
var jump_point:Area2D=null
@onready var control=$AI
@onready var nav_agent=$Navigator.nav_agent

func _ready():
	super._ready()
	min_speed=max_speed/2
	if !Global.endless and tessa and !Global.get_flag("with_tessa") and "Cherry" in main.npcs:
		if !is_instance_valid(main.npcs["Cherry"]):
			queue_free()
			return
		global_position=main.npcs["Cherry"].global_position
	if nav_agent.avoidance_enabled:
		nav_agent.velocity_computed.connect(nav_velocity_computed)

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
	#navigator.nav_agent.set_velocity(velocity)
	#var coll = move_and_collide(velocity*delta,true)
	#if coll:
	#	collision.emit(coll)
	move_and_slide()
	if velocity.length()<.5:
		global_position=global_position.round()

func nav_velocity_computed(new_velocity):
	if nav_agent.avoidance_enabled and !nav_agent.is_navigation_finished():
		var speed=velocity.length()
		velocity=new_velocity.normalized()*speed
