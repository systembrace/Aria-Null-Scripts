extends Area2D

@export var control: PlayerControl
@onready var main:Main=get_tree().get_root().get_node("Main")

func _process(_delta):
	if main.transition.fade or control.paused or !Input.is_action_just_pressed("interact"):
		return
	var interacted=false
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			if area is Interactable and area.can_interact:
				area.interact(get_parent())
				interacted=true
				break
	elif has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body is Ally and body.can_speak_to:
				body.interact(get_parent())
				interacted=true
				break
	if interacted:
		$Interact.play()
