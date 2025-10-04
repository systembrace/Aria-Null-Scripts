extends Node
class_name SignalConnector

@export var signal_node:Node
@export var signal_name:String
@export var connect_node:Node
@export var call_function=true
@export var func_name:String
@export var attribute_name:String
@export var has_param=false
@export var param=0

func _ready():
	if signal_node and connect_node:
		if call_function:
			signal_node.get(signal_name).connect(exec_func)
		else:
			signal_node.get(signal_name).connect(connect_node.set.bind(attribute_name,param))

func exec_func(_params=null):
	if !is_instance_valid(connect_node):
		queue_free()
		return
	if !has_param:
		connect_node.call(func_name)
	else:
		connect_node.call(func_name,param)
