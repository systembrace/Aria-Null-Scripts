extends Node2D
class_name Navigator

@export var snap_pos=false
@onready var nav_agent=$NavigationAgent2D
@onready var timer=$Timer

func _ready():
	timer.wait_time=.2

func next_direction(targetpos):
	if timer.is_stopped() or targetpos.distance_to(nav_agent.get_next_path_position())>16:
		nav_agent.target_position=targetpos
		timer.start()
	return (nav_agent.get_next_path_position()-global_position).normalized()

func _process(_delta):
	if snap_pos:
		global_position.x=snappedi(get_parent().global_position.x,16)
		global_position.y=snappedi(get_parent().global_position.y,16)
