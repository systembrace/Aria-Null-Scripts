extends State
class_name EnemyAttack

@export var attack_dist=192
@export var attack_chance=.75
@export var combo:Combo
@export var circle_min=.5
@export var circle_max=1.5
@export var navigator:Navigator
@export var has_combos=false
@export var hurtbox_retaliation:Hurtbox
@export var special_chance=0.0
@export var special_index=0
var target: Node2D
var direction=Vector2.ZERO
var speed
var accel
var circling=false
var attackpush=false
var move_to=Vector2.ZERO
@onready var timer=$CircleTimer

func _ready():
	timer.timeout.connect(new_dir)
	if hurtbox_retaliation:
		hurtbox_retaliation.take_hit.connect(retaliate)

func retaliate(_attack=null, _parry=false):
	circling=false
	if not combo.is_attacking() and not combo.can_attack():
		combo.current_attack.finishedtimer.stop()
		combo.current_attack.buffer.stop()
		combo.current_attack.finish_attack()
		combo.current_attack.enable_attack()
	timer.stop()

func new_dir(in_out=1):
	if circling:
		if combo.can_attack():
			circling=false
			return
		if is_instance_valid(target):
			move_to=((target.global_position-body.global_position).normalized()*in_out).rotated(randi_range(-1,1)*PI/3).rotated(randf_range(-PI/4,PI/4))/2
		timer.wait_time=randf_range(circle_min,circle_max)
		timer.start()

func enter():
	if not is_instance_valid(body.target):
		body.target=null
		transition.emit(self,"return")
		return
	target=body.target
	speed=body.max_speed
	accel=body.accel
	circling=false
	attackpush=false
	timer.stop()
	direction=Vector2.ZERO
	move_to=body.to_local(body.target.global_position).normalized()
	combo.enable_attack()

func update():
	var targetdist=9999
	if is_instance_valid(target):
		targetdist=body.global_position.distance_to(target.global_position)
	else:
		transition.emit(self, "wander")
		return
	if targetdist>attack_dist and combo.can_attack():
		transition.emit(self, "follow")
	
	if combo.is_done_attacking():
		if targetdist<=combo.reach() and target.control.health.hp>0:
			if not circling and (combo.can_attack() or (has_combos and combo.is_recovering() and combo.combo_index<combo.last)):
				if randf()<attack_chance:
					circling=false
					direction=Vector2.ZERO
					move_to=Vector2.ZERO
					if combo.can_attack() and randf()<special_chance:
						combo.attack_index(special_index)
					else:
						combo.attack()
				else:
					combo.disable_hitbox()
			elif not circling:
				circling=true
				new_dir(-1)
		elif targetdist>combo.push/4.0 and targetdist<=combo.push/3.0:
			circling=false
			move_to=navigator.next_direction(target.global_position)
		elif not circling:
			circling=true
			new_dir()
	
	direction=direction.lerp(move_to,.1)
	if not circling:
		timer.stop()
	elif targetdist<combo.push/10.0:
		direction+=(body.global_position-target.global_position).normalized()/targetdist

func physics_update():
	body.velocity=body.velocity.move_toward(direction*speed,accel)
	if not attackpush and combo.is_damaging():
		attackpush=true
		body.velocity=combo.attack_push()
	elif not combo.is_damaging():
		attackpush=false

func exit():
	#body.velocity=Vector2.ZERO
	combo.enable_attack()
