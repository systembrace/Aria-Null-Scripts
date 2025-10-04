extends Event
class_name WaitEvent

@export var wait_time=1.0
@export var pause_player=false

func activate():
	if active or completed:
		return
	super.activate()
	if pause_player:
		main.player.control.set_deferred("paused",true)
	if coroutine:
		get_tree().create_timer(wait_time,false).timeout.connect(finish_task)
	else:
		get_tree().create_timer(wait_time,false).timeout.connect(complete)

func complete():
	if !active or waiting or completed:
		return
	if pause_player:
		main.player.control.paused=false
	super.complete()
