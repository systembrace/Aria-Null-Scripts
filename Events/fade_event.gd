extends Event
class_name FadeEvent

@export var fade_out=true
@export var time=1.0

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	if fade_out:
		main.transition.reverse_fade(time)
		main.transition.faded_out.connect(complete)
	else:
		main.transition.fade_out(time)
		main.transition.finished.connect(complete)

func complete():
	if !skipped:
		if fade_out:
			main.transition.faded_out.disconnect(complete)
		else:
			main.transition.finished.disconnect(complete)
	super.complete()
