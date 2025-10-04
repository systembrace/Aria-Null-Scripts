extends Node
class_name Counter

@export var node:Node
@export var func_name:String
@export var goal=1
signal finished
var num=0

func count():
	num+=1
	if num>=goal:
		node.call(func_name)
		finished.emit()
