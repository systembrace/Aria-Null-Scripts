extends Event
class_name TriggerEvent

@export var body_names=["Player"]
@onready var area=$Area2D
@onready var coll: CollisionShape2D = $Area2D/CollisionShape2D

func _ready():
	super._ready()
	area.set_collision_layer_value(1,false)
	area.set_collision_mask_value(1,false)
	area.set_collision_mask_value(9,true)
	area.body_entered.connect(on_body_entered)
	if !early_skip:
		coll.set_deferred("disabled",true)
	
func activate():
	if active or completed:
		return
	super.activate()
	if !early_skip:
		coll.set_deferred("disabled",false)
	for body in area.get_overlapping_bodies():
		var found=on_body_entered(body)
		if found:
			break

func on_body_entered(body):
	if (completed and not coroutine) or (coroutine and coroutine_done and !branch):
		return false
	if body.name in body_names:
		if coroutine:
			finish_task()
		else:
			complete()
		coll.set_deferred("disabled",true)
		return true
	else:
		return false
