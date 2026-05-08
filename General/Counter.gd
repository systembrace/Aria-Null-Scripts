extends Node
class_name Counter

@export var node:Node
@export var func_name:String
@export var goal=1
signal finished
var num=0
var enabled=false

func _ready():
	get_tree().create_timer(0.5).timeout.connect(set.bind("enabled",true))

func count():
	num+=1
	if num>=goal and enabled:
		node.call(func_name)
		finished.emit()
