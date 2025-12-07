extends Node2D
class_name Wave

@export var enemies_left_to_next_wave=0
@export var enabled=true
signal wave_enabled
signal wave_started

func _ready():
	disable()
	y_sort_enabled=true

func disable():
	visible=false
	process_mode=Node.PROCESS_MODE_DISABLED

func enable():
	if enabled && not visible:
		start()
	else:
		wave_enabled.emit()
		enabled=true

func start():
	if get_child_count()==0:
		return
	process_mode=Node.PROCESS_MODE_INHERIT
	enabled=true
	visible=true
	wave_started.emit()
