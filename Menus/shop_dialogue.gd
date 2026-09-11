extends Button
class_name ShopDialogueButton

@export var require_flag=""
@export var names:Array[String]=[]
var talk_tab: TalkTab
var child_map={}
var index=0

func _ready():
	pressed.connect(execute)
	for child in get_children():
		child_map[child.name]=child
	check_flags()

func check_flags():
	if require_flag!="":
		if !Global.get_permanent_data("global",require_flag):
			hide()
		else:
			show()

func execute():
	if index>=len(names):
		return true
	var event_name=names[index]
	index+=1
	if "." in event_name:
		var child_name=event_name.substr(0,event_name.find("."))
		if child_name in child_map:
			child_map[child_name].call(event_name.substr(event_name.find(".")+1))
			if index>=len(names):
				return true
			call_deferred("execute")
	else:
		talk_tab.play_dialogue(self, event_name)
	return false
