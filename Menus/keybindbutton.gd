extends Button
class_name KeybindButton

func set_labels(action,event):
	$MarginContainer/HBoxContainer/Action.text=action
	$MarginContainer/HBoxContainer/Event.text=event

func wait_input():
	$MarginContainer/HBoxContainer/Event.text="[Input]"
