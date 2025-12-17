extends Node2D
class_name Wave

@export var enemies_left_to_next_wave=0
@export var enabled=true
var started=false
signal wave_enabled
signal wave_started

func _ready():
	disable()
	y_sort_enabled=true

func disable():
	#for child in get_children():
	#	if not child is Spawner:
	#		child.hide()
	process_mode=Node.PROCESS_MODE_DISABLED

func enable():
	if enabled && not started:
		start()
	else:
		wave_enabled.emit()
		enabled=true

func start():
	var enemy_count=0
	for child in get_children():
		if child is Enemy or child is Spawner:
			enemy_count+=1
	if enemy_count==0 or started:
		return
	started=true
	process_mode=Node.PROCESS_MODE_INHERIT
	for child in get_children():
		if child is Spawner:
			child.activate()
		#else:
		#	child.show()
	enabled=true
	wave_started.emit()
