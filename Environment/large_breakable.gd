extends Breakable
class_name LargeBreakable

@export var smaller_breakable=""
@export var break_points:Array[Node2D]=[]

func create_smaller_breakables():
	var main=get_tree().get_root().get_node("Main")
	var i=1
	var new_breakables=[]
	for break_point in break_points:
		var breakable=load("res://Scenes/Environment/"+smaller_breakable+".tscn").instantiate()
		breakable.global_rotation=break_point.global_rotation
		breakable.global_position=break_point.global_position
		main.call_deferred("add_child",breakable)
		breakable.name=name+"_"+str(i)
		breakable.add_to_group("objs_to_load")
		new_breakables.append(breakable)
		i+=1
	return new_breakables

func set_broken():
	broken=true
	var new_breakables=create_smaller_breakables()
	$CollisionShape2D.call_deferred("swap",true)
	for child in get_children():
		child.queue_free()
	return new_breakables

func die():
	create_smaller_breakables()
	super.die()
