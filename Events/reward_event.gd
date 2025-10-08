extends Event
class_name RewardEvent

@export var scrap=20
@export var pause_player=true

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed):
		active=true
		complete()
		return
	super.activate()
	if !main.is_node_ready():
		await main.ready
	if pause_player:
		main.player.control.pause()

func _process(_delta):
	if active:
		main.player.control.collect_scrap()
		scrap-=1
		if scrap<=0:
			if pause_player:
				main.player.control.set_deferred("paused",false)
			complete()
