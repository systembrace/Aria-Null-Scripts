extends Event
class_name ActionEvent

@export var action_name="hologram"

func _process(_delta):
	if completed or !activated or skipped:
		return
	if Input.is_action_just_released(action_name):
		complete()
