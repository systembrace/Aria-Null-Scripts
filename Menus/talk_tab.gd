extends MenuTab
class_name TalkTab

@export var npc_name="elmsable"
signal talked
var current_option:ShopDialogueButton
@onready var options=$Options
@onready var dialogue_box=$Dialogue

func _ready():
	for child in get_children():
		if child is ShopDialogueButton:
			child.reparent(options)
			child.talk_tab=self

func play_dialogue(option,section):
	current_option=option
	options.hide()
	dialogue_box.show()
	var data=ConfigFile.new()
	data.load("res://Dialogue/"+npc_name+".ini")
	dialogue_box.enter(data,section,false,false,false,-1,false)

func dialogue_end():
	var done=current_option.execute()
	if done:
		current_option.index=0
		for child in options.get_children():
			if child is ShopDialogueButton:
				child.check_flags()
		options.show()
		dialogue_box.hide()
