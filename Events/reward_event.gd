extends Event
class_name RewardEvent

@export var scrap=20

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_skipped and ignore_when_event_skipped.completed):
		active=true
		complete()
		return
	super.activate()
	if !main.is_node_ready():
		await main.ready
	main.player.control.set_deferred("paused",true)

func _process(_delta):
	if active:
		main.player.control.collect_scrap()
		scrap-=1
		if scrap<=0:
			main.player.control.set_deferred("paused",false)
			complete()
