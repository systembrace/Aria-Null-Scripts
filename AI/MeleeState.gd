extends LockonState
class_name MeleeAttack

@export var combo: Combo
@export var shoot_chance=0.0
@export var attack_chance=.7
@export var attack_frequency=.08
@export var has_combos=false
@export var parrychance=0.0
@export var specialchance=0.0
@export var specialindex=[]
@export var hurtbox_retaliation:Hurtbox
@export var circling_time=2
var must_attack=false
var special=-1
var trying_parry=false
var attacking=false
var parry_timer:Timer
var attackpush=false
var still_time=0.0
var trans_to_attack_state=false
@onready var attack_timer=$MaxTimer
@onready var try_timer=$TryTimer

func _ready():
	attack_timer.timeout.connect(attack)
	attack_timer.wait_time=circling_time
	try_timer.timeout.connect(try_attacking)
	try_timer.wait_time=attack_frequency
	if hurtbox_retaliation:
		hurtbox_retaliation.take_hit.connect(retaliate)

func enter():
	super.enter()
	try_timer.start()
	attack_timer.start()
	still_time=0
	if parrychance>0:
		parry_timer=Timer.new()
		add_child(parry_timer)
		parry_timer.one_shot=true
		parry_timer.timeout.connect(attack)
	
func retaliate(_attack=null, _parry=false):
	if combo.can_attack() and !combo.is_readying() and combo.is_done_attacking():
		attack()
	
func attack():
	must_attack=true
	
func capable_of_attack():
	return can_see_target() and targetdist<combo.reach(special) and (combo.can_attack() or (has_combos and combo.is_recovering() and !combo.end_of_combo()) or (special==-1 and combo.current_attack.is_special and combo.is_done_attacking()) or (special>-1 and combo.is_done_attacking()))

func try_attacking():
	if !combo.is_done_attacking() or must_attack or trying_parry:
		return
	if randf()*circling_time/2*60/(attack_chance*1.5)<still_time:
		must_attack=true
		return
	var attack_roll=randf()
	var should_attack=attack_roll<=attack_chance or (target.control.stunned and attack_roll<=attack_chance*1.5)
	if should_attack and (combo.current_combo==combo.combo_index or combo.end_of_combo()) and !combo.current_attack.combo_index in specialindex and randf()<=specialchance:
		special=specialindex[randi_range(0,len(specialindex)-1)]
		combo.set_index(special)
	must_attack = capable_of_attack() and (should_attack or target is RolyPoly)
	if must_attack:
		return
	special=-1
	if parrychance==0:
		return
	raytarget(target.global_position)
	if !ray.is_colliding() and randf()<=parrychance and is_instance_valid(target.control.combo) and target.control.combo.is_readying():
		trying_parry=true
		combo.enable_attack()
		if combo.current_attack is ChargedAttack:
			combo.attack()
		parry_timer.wait_time=target.control.combo.time_until_attack()
		if !combo.is_charging():
			parry_timer-=combo.current_attack.delay_time
		if parry_timer.wait_time>0:
			parry_timer.start()
		else:
			combo.enable_attack()

func update():
	if target!=body.target and combo.can_move():
		target=body.target
		if is_instance_valid(target):
			reset_dest()
		direction=Vector2.ZERO
	if !is_instance_valid(target) or target.control.health.hp<=0:
		if combo.can_move():
			transition.emit(self,"Wander")
		try_timer.stop()
		return
	if combo.is_damaging() and combo.current_attack.transition_to!="":
		trans_to_attack_state=true
		transition.emit(self, combo.current_attack.transition_to)
		return
	if !combo.is_done_attacking() and !trying_parry:
		try_timer.stop()
		if !combo.can_navigate() or combo.is_readying():
			direction=Vector2.ZERO
		elif combo.can_navigate():
			var temp_min=min_dist
			var temp_max=max_dist
			min_dist=0
			max_dist=combo.current_attack.push
			super.update()
			min_dist=temp_min
			max_dist=temp_max
		must_attack=false
		attacking=true
		return
	
	if is_instance_valid(target) and target.velocity.length()<.25:
		still_time+=1
	else:
		still_time=0
	
	update_targetdist()
	if targetdist>combat_dist:
		transition.emit(self,"Follow")
	if shoot_chance>0 and body.ammo>=30.0 and (targetdist>max_dist*2 or (targetdist>max_dist and randf()<=shoot_chance)):
		transition.emit(self,"Shoot")
		return
	if attacking:
		attacking=false
		reset_dest()
		attack_timer.start()
		try_timer.start()
		if has_combos and !combo.end_of_combo():
			try_attacking()
	
	#attack
	if must_attack and (capable_of_attack() or trying_parry):
		attack_timer.stop()
		must_attack=false
		if !combo.can_navigate():
			direction=Vector2.ZERO
		if trying_parry and combo.is_charging():
			trying_parry=false
			combo.release()
			return
		trying_parry=false
		if special>-1:
			if combo.attack_index(special):
				special=-1
				return
			else:
				must_attack=true
		if !combo.attack():
			must_attack=true
		if combo.is_charging():
			combo.release()
	
	super.update()
	
func physics_update():
	var tempspeed=speed
	var tempaccel=accel
	if combo.is_done_attacking() and targetdist<=max_dist+16 and can_see_target():
		tempspeed/=2.0
	if combo.is_charging():
		tempspeed/=4.0
	if !combo.is_done_attacking() and combo.can_navigate():
		stay_away=false
		tempspeed*=2.0*combo.current_attack.nav_speed_scale
		tempaccel*=combo.current_attack.nav_accel_scale
	elif try_stay_away and !stay_away:
		stay_away=true
	if stay_away and targetdist<min_dist/2:
		tempspeed*=2.0
	body.velocity=body.velocity.move_toward(direction*tempspeed,tempaccel)
	if not attackpush and combo.is_damaging() and not combo.can_navigate():
		attackpush=true
		body.nav_agent.avoidance_enabled=false
		body.velocity=combo.attack_push()
	elif not combo.is_damaging():
		attackpush=false
		if combo.can_navigate():
			body.nav_agent.avoidance_enabled=true

func exit():
	must_attack=false
	try_timer.stop()
	attack_timer.stop()
	attackpush=false
	if !trans_to_attack_state:
		combo.enable_attack()
	trans_to_attack_state=false
	if parry_timer:
		parry_timer.stop()
