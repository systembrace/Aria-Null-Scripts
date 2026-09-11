extends Event
class_name MusicEvent

@export var change_mute=false
@export var muted=false

func activate():
	if active or completed:
		return
	if branch or should_ignore():
		active=true
		complete()
		if branch_when_ignored and should_ignore():
			branch_when_ignored.branch_here(self)
		return
	super.activate()
	if change_mute:
		Music.set_mute(muted)
