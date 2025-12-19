extends Event
class_name ActorVisEvent

@export var show=true

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	if show:
		main.player.show()
		main.player.scarf.show()
		main.inventory.hud.hpbar.show()
		main.inventory.hud.portrait.show()
		main.inventory.hud.scrapicon.show()
	else:
		main.player.hide()
		main.player.scarf.hide()
		main.inventory.hud.hpbar.hide()
		main.inventory.hud.portrait.hide()
		main.inventory.hud.scrapicon.hide()
	complete()
