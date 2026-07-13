extends MenuTab
class_name TalkTab

@export var npc_name="elmsable"
signal talked
@onready var options=$Options
@onready var dialogue_box=$Dialogue

func _ready():
	for child in get_children():
		if child is Button:
			child.reparent(options)
			child.pressed.connect(play_dialogue.bind(child.name))

func play_dialogue(section):
	options.hide()
	dialogue_box.show()
	var data=ConfigFile.new()
	data.load("res://Dialogue/"+npc_name+".ini")
	dialogue_box.enter(data,section,false,false,false,-1,false)

func dialogue_end():
	options.show()
	dialogue_box.hide()
