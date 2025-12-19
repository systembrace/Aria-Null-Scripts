extends Event
class_name WaitEvent

@export var wait_time=1.0

func activate():
	if active or completed:
		return
	super.activate()
	if coroutine:
		get_tree().create_timer(wait_time,false).timeout.connect(finish_task)
	else:
		get_tree().create_timer(wait_time,false).timeout.connect(complete)

func complete():
	if !active or waiting or completed:
		return
	super.complete()
