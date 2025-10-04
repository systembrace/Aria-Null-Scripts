extends VBoxContainer

var overwriting=false
var selected_button
var selected_action
var actions={
	"left":"Move left",
	"right":"Move right",
	"up":"Move up",
	"down":"Move down",
	"attack":"Attack",
	"secondary":"Use alt",
	"dash":"Dodge",
	"heal":"Heal",
	"use item":"Use equipped item",
	"aim":"Aim (for no mouse)",
	"next gun":"Next alt",
	"next item":"Next item",
	"interact":"Interact",
	"inventory":"Open inventory",
	"back":"Back",
	"pause":"Pause game"
}
var default_binds={
	"left":"A",
	"right":"D",
	"up":"W",
	"down":"S",
	"attack":"Mouse 1",
	"secondary":"Mouse 2",
	"dash":"Shift",
	"heal":"Q",
	"use item":"Space",
	"aim":"P",
	"next gun":"Ctrl",
	"next item":"Alt",
	"interact":"E",
	"inventory":"Tab",
	"back":"Escape",
	"pause":"Escape"
}
var previous_binds
var current_binds
@onready var timer=$Timer

func _ready():
	previous_binds=Global.load_keybinds()
	current_binds=Global.load_keybinds()
	timer.wait_time=1
	update_buttons()

func update_buttons():
	for child in get_children():
		if child is KeybindButton:
			child.free()
	for action in actions.keys():
		var button=load("res://Scenes/UI/keybindbutton.tscn").instantiate()
		if !action in current_binds.keys():
			Global.save_config("bindings",action,default_binds[action])
			previous_binds=Global.load_keybinds()
			current_binds=Global.load_keybinds()
		button.set_labels(actions[action],current_binds[action])
		button.pressed.connect(button_pressed.bind(button,action))
		add_child(button)
		if visible:
			button.disabled=false

func reset_bindings(to_default=false):
	if to_default:
		current_binds=default_binds.duplicate()
	else:
		current_binds=previous_binds.duplicate()
	update_buttons()

func save_bindings():
	Global.set_input_map(current_binds)
	Global.save_keybinds(current_binds)
	previous_binds=current_binds.duplicate()

func button_pressed(button,action):
	if !overwriting and timer.is_stopped():
		overwriting=true
		selected_button=button
		selected_action=action
		button.wait_input()

func _input(event):
	if overwriting and (event is InputEventKey || (event is InputEventMouseButton && event.pressed)):
		if event is InputEventMouseButton:
			current_binds[selected_action]="Mouse "+str(event.button_index)
		else:
			current_binds[selected_action]=OS.get_keycode_string(event.keycode)
		selected_button.set_labels(actions[selected_action],current_binds[selected_action])
		overwriting=false
		timer.start()
