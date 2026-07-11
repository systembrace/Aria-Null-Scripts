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
	if show_actor:
		if actor=="player":
			main.player.show()
			main.player.scarf.show()
			main.inventory.hud.hpbar.show()
			main.inventory.hud.portrait.show()
			main.inventory.hud.scrapicon.show()
		else:
			main.npcs[actor].show()
	else:
		if actor=="player":
			main.player.hide()
			main.player.scarf.hide()
			main.inventory.hud.hpbar.hide()
			main.inventory.hud.portrait.hide()
			main.inventory.hud.scrapicon.hide()
		else:
			main.npcs[actor].hide()

func skip(trueskip=false):
	super.skip(trueskip)
	execute()
