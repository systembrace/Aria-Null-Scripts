extends Event
class_name TriggerEvent

@export var body_names=["Player"]
@export var early_skip=false
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

func on_body_entered(body):
	if (completed and not coroutine) or (coroutine and coroutine_done and !branch):
		return
	if body.name in body_names:
		if !prev.completed and early_skip:
			skip()
		elif coroutine:
			finish_task()
		else:
			complete()
		coll.set_deferred("disabled",true)
