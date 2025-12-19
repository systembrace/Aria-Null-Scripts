extends Event
class_name SetNPCAnim

@export var actor_name="Cherry"
@export var anim_name="none"
var actor

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	actor=main.npcs[actor_name]
	actor.anim_controller.cutscene_anim=anim_name
	complete()
