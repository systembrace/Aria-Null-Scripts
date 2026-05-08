extends Node2D
class_name Combo

@export var hurtbox_for_rally: Hurtbox
var attack_list={}
var combo_index=0
var prev_index=0
var current_attack: Attack
var push=0
var combo_sets={}
var current_combo=0
signal parry
signal started_ready
signal started_attack
signal ended_attack
signal fully_charged

func _ready():
	for child in get_children():
		if child is Attack:
			attack_list[child.combo_index]=child
			child.parry.connect(emit_parry)
			child.started_ready.connect(emit_ready.bind(child))
			child.started_attack.connect(emit_attack)
			child.ended_attack.connect(emit_end.bind(child))
			if child is ChargedAttack:
				child.fully_charged.connect(emit_charged)
			if !child.unique_sfx and find_child("SFXAttack"):
				if find_child("SFXReady"):
					child.started_ready.connect(find_child("SFXReady").play)
				child.started_attack.connect(find_child("SFXAttack").play)
			elif child.unique_sfx and find_child("SFXAttack_"+str(child.combo_index)):
				if find_child("SFXReady_"+str(child.combo_index)):
					child.started_ready.connect(find_child("SFXReady_"+str(child.combo_index)).play)
				child.started_attack.connect(find_child("SFXAttack_"+str(child.combo_index)).play)
			if child.pick_weight==0.0 and !child.is_special:
				current_combo=child.combo_index
				combo_sets[current_combo]=[child.combo_index]
			elif !child.is_special:
				combo_sets[current_combo].append(child.combo_index)
	current_combo=0
	current_attack=attack_list[combo_index]
	push=current_attack.push

func set_index(index=combo_index+1):
	prev_index=combo_index
	combo_index=index

func end_of_combo():
	if combo_index>=len(attack_list.keys()):
		return true
	return current_combo!=combo_index and combo_sets[current_combo][-1]!=combo_index

func emit_parry(parried_by=null):
	if hurtbox_for_rally and (not parried_by is Bullet or parried_by.faction=="enemy") and not parried_by is Harpoon:
		hurtbox_for_rally.disable_hurtbox()
		if not parried_by:
			hurtbox_for_rally.cancel_damage()
	parry.emit(parried_by)

func emit_ready(_attack=null):
	started_ready.emit()

func emit_attack():
	started_attack.emit()

func emit_end(_attack=null):
	ended_attack.emit()

func emit_charged():
	fully_charged.emit()

func attack_index(index):
	if index>=len(attack_list) or (attack_list[index].is_special and (!attack_list[index].can_attack or !can_attack())):
		return false
	set_index(index)
	current_attack=attack_list[combo_index]
	current_attack.start_attack()
	if current_attack.is_special:
		restart_combo()
	else:
		set_index()
	return true

func restart_combo():
	if len(combo_sets)<=1:
		set_index(0)
		current_combo=0
		return
	set_index(combo_sets.keys()[randi_range(0,len(combo_sets)-1)])
	current_combo=combo_index

func attack():
	if can_attack():
		restart_combo()
	elif combo_index>=len(attack_list):
		return false
	elif combo_index==current_combo and !attack_list[combo_sets[current_combo][-1]].can_attack:
		return false
	current_attack=attack_list[combo_index]
	if combo_index==current_combo:
		current_attack.start_attack()
		set_index()
		return true
	var prev_attack=attack_list[prev_index]
	if !prev_attack.done_attacking:
		return false
	if not prev_attack.can_attack:
		if randf()<=current_attack.pick_weight:
			current_attack.start_attack()
			set_index()
		else:
			restart_combo()
		return true
	return false
	
func is_charging():
	if current_attack is ChargedAttack and is_readying():
		return true
	return false

func release():
	if current_attack is ChargedAttack:
		current_attack.release()

func stun_counterattack(area):
	Global.hitstop(.15)
	restart_combo()
	current_attack=attack_list[combo_index]
	current_attack.look_at(area.targetparent.global_position)
	current_attack.attack()
	current_attack.parry.emit()
	area.parry.emit(current_attack)
	area.disable_hitbox()
	set_index()

func stop_attack():
	current_attack.stop_attack()

func disable_hitbox(override=false):
	for i in attack_list:
		if i!=combo_index:
			attack_list[i].disable_hitbox()
	if override or current_attack.interruptible:
		current_attack.disable_hitbox()
	if override:
		current_attack.can_attack=false
		current_attack.damaging=false
		current_attack.done_attacking=true

func enable_attack():
	for i in attack_list:
		attack_list[i].enable_attack()
	set_index(0)
	for child in get_children():
		if child is SoundPlayer:
			child.stop()

func time_until_attack():
	return current_attack.delay.time_left

func is_readying():
	return current_attack.readying

func is_attacking():
	return current_attack.attacking

func is_damaging():
	return current_attack.damaging

func is_parriable():
	return current_attack.parriable

func is_done_attacking():
	return current_attack.done_attacking

func is_recovering():
	return current_attack.recovering

func can_navigate():
	return current_attack.can_navigate

func can_move():
	return current_attack.can_move

func can_attack():
	return current_attack.can_attack and attack_list[combo_sets[current_combo][-1]].can_attack

func reach(index=-1):
	if index>-1 and index<len(attack_list):
		return attack_list[index].reach
	if combo_index>=len(attack_list):
		return current_attack.reach
	return attack_list[combo_index].reach

func attack_push(modifier=0):
	return Vector2.RIGHT.rotated(current_attack.global_rotation)*(current_attack.push+modifier)

func attack_vector():
	if not current_attack.find_child("CollisionShape2D").shape is RectangleShape2D:
		return Vector2.RIGHT.rotated(current_attack.global_rotation)*(current_attack.find_child("CollisionShape2D").shape.height)
	return Vector2.ZERO
