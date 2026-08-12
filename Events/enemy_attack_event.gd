extends Event
class_name EnemyAttackEvent

@export var enemy: Enemy
@export var combo_index=0

func activate():
	if active or completed:
		return
	if !is_instance_valid(enemy) or branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	enemy.target=self
	var control=enemy.control
	var attack=control.combo.attack_list[combo_index]
	control.dont_notice=true
	control.combo.enable_attack()
	control.force_transition("Attack")
	control.process_physics=false
	attack.started_attack.connect(started_attack)
	control.combo.attack_index(combo_index)
	attack.ended_attack.connect(complete)

func started_attack():
	enemy.control.process_physics=true

func complete():
	if !active or waiting or completed:
		return
	if is_instance_valid(enemy) and enemy.control.combo.attack_list[combo_index].ended_attack.is_connected(complete):
		enemy.control.combo.attack_list[combo_index].ended_attack.disconnect(complete)
		enemy.target=null
		enemy.control.dont_notice=false
	super.complete()
