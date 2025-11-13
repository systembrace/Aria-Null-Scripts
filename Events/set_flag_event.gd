extends Event
class_name SetFlagEvent

@export var flag_name:String
@export var value=0.0
@export var save_flags=false
@export var checkpoint=false
var being_trueskipped=false

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed):
		active=true
		complete()
		return
	super.activate()
	if not being_trueskipped:
		Global.set_flag(flag_name,value)
		if save_flags:
			Global.save_flags(checkpoint)
		complete()

func skip(trueskip=false):
	being_trueskipped=trueskip
	super.skip(trueskip)
