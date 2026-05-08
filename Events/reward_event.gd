extends Event
class_name RewardEvent

@export var scrap=20
var step=0

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	if !main.is_node_ready():
		await main.ready

func _process(delta):
	step+=60*delta
	if active and step>=1:
		step-=1
		main.player.control.collect_scrap()
		scrap-=1
		if scrap<=0:
			complete()
