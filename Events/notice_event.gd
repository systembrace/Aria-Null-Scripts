extends Event
class_name NoticeEvent

@export var notice=""

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	main.inventory.hud.show_notice(notice)
	complete()
