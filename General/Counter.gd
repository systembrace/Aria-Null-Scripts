extends Node
class_name Counter

@export var node:Node
@export var func_name:String
@export var un_func_name:String
@export var goal=1
signal finished
signal undo
var num=0
var enabled=false

func _ready():
	get_tree().create_timer(0.5).timeout.connect(set.bind("enabled",true))

func count():
	num+=1
	if num>=goal and enabled:
		node.call(func_name)
		finished.emit()

func uncount():
	num-=1
	if num==goal-1 and enabled:
		if un_func_name:
			node.call(un_func_name)
		undo.emit()
