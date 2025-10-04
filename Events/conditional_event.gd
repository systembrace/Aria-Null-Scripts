extends Event
class_name DamageTriggerEvent

@export var jump_event: Event

func _ready():
	coroutine=true
	super._ready()

func activate():
	if !coroutine_done or active or completed:
		return
	if !main.is_node_ready():
		await main.ready
	if main.transition.fade:
		await main.transitionfinished
	main.player.control.health.hplost.connect(jump.unbind(1))
	if next.coroutine:
		next.task_finished.connect(finish_task)
	else:
		next.just_completed.connect(finish_task)
	super.activate()

func jump():
	jump_event.branch=false
	jump_event.completed=false
	jump_event.activate()

func finish_task():
	if main.player.control.health.hplost.is_connected(jump):
		main.player.control.health.hplost.disconnect(jump)
	super.finish_task()
