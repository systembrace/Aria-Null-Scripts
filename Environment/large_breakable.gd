extends Breakable
class_name LargeBreakable

@export var smaller_breakable=""
@export var break_points:Array[Node2D]=[]

func create_smaller_breakables():
	var main=get_tree().get_root().get_node("Main")
	for break_point in break_points:
		var breakable=load("res://Scenes/Environment/"+smaller_breakable+".tscn").instantiate()
		breakable.global_rotation=break_point.global_rotation
		breakable.global_position=break_point.global_position
		main.call_deferred("add_child",breakable)

func set_broken():
	broken=true
	create_smaller_breakables()
	$CollisionShape2D.call_deferred("swap",true)
	for child in get_children():
		child.queue_free()

func die():
	create_smaller_breakables()
	super.die()
