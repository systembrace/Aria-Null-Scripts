extends Event
class_name DialogueEvent

@export var pause_player=true

func activate():
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed):
		active=true
		complete()
		return
	if active or completed:
		return
	if !main.is_node_ready():
		await main.ready
	print("playing dialogue "+name)
	super.activate()
	main.player.inventory.hud.dialogue(main.scene_name,name,coroutine,pause_player)
	Global.dialogue_ended.connect(dialogue_ended)

func dialogue_ended():
	print("dialogue "+name+" ended")
	if coroutine:
		finish_task()
	else:
		complete()
	Global.dialogue_ended.disconnect(dialogue_ended)
