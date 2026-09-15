extends Event
class_name ActorVisEvent

@export var actor="player"
@export var show_actor=true

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	execute()
	complete()

func execute():
	if actor=="player":
		main.player.visible=show_actor
		main.player.scarf.visible=show_actor
		main.inventory.hud.hpbar.visible=show_actor
		main.inventory.hud.portrait.visible=show_actor
		main.inventory.hud.scrapicon.visible=show_actor
	else:
		main.npcs[actor].visible=show_actor

func skip(trueskip=false):
	super.skip(trueskip)
	execute()
