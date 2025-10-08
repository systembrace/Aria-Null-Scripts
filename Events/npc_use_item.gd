extends Event
class_name NPCItemEvent

@export var actor_name="Cherry"
@export var target: Node2D
@export var using_gun=true
@export var item_name="Gun"
@export var delay_time=.5
@export var grapple_retract_time=1.25
var actor: Entity
var temp_target
var temp_equip
var shoot_state

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed):
		active=true
		complete()
		return
	super.activate()
	actor=main.npcs[actor_name]
	if !is_instance_valid(target):
		target=self
	temp_target=actor.target
	actor.target=target
	if !using_gun:
		return #items not implemented yet
	shoot_state=actor.control.states["shoot"]
	if !is_instance_valid(shoot_state):
		return
	temp_equip=shoot_state.gun.name
	shoot_state.equip_gun(item_name)
	var temp_time=shoot_state.delay_time
	shoot_state.set_delay(delay_time)
	shoot_state.try_shoot()
	shoot_state.set_delay(temp_time)
	if shoot_state.gun is Grapple:
		get_tree().create_timer(grapple_retract_time,false).timeout.connect(retract_harpoon)
	else:
		get_tree().create_timer(delay_time+.05,false).timeout.connect(complete)

func complete():
	if !skipped:
		actor.target=temp_target
		if using_gun:
			shoot_state.equip_gun(temp_equip)
	super.complete()

func retract_harpoon():
	shoot_state.guns[item_name].use()
	complete()
