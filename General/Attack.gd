extends Hitbox
class_name Attack

@export var stop_targeting=.01
@export var delay_time=.01
@export var min_attack_time=0.0
@export var attack_time=.2
@export var parry_time:float=0.0
@export var finished_time:float=.1
@export var buffer_time=.15
@export var push=200.0
@export var reach=0.0
@export var hitbox_flicker=0.0
@export var interruptible=true
@export var can_navigate=false
@export var pick_weight:float=1
@export var combo_index=0
@export var is_special=false
@export var unique_anim=false
@export var has_recovery=true
@export var unique_sfx=false
signal parry(area)
var target: Node2D
@onready var attack_timer=$AttackTimer
@onready var parry_timer=$ParryTimer
@onready var buffer=$BufferTimer
@onready var delay=$DelayTimer
@onready var targettimer=$TargetTimer
@onready var finishedtimer=$FinishedTimer
signal started_ready
signal started_attack
signal ended_attack
var attacking=false
var parriable=false
var damaging=false
var can_attack=true
var done_attacking=true
var readying=false
var recovering=false
var can_move=true

func _ready():
	if reach==0.0:
		reach=abs(push)/6.0
	if parry_time==0:
		parry_time=attack_time
	attack_timer.timeout.connect(stop_attack)
	attack_timer.wait_time=attack_time
	parry_timer.timeout.connect(disable_parry)
	parry_timer.wait_time=parry_time
	buffer.timeout.connect(enable_attack)
	buffer.wait_time=buffer_time
	delay.timeout.connect(attack)
	delay.wait_time=delay_time
	if stop_targeting>0:
		targettimer.timeout.connect(look_target)
		targettimer.wait_time=stop_targeting
	if finished_time!=0:
		finishedtimer.timeout.connect(finish_attack)
		finishedtimer.wait_time=finished_time
	if hitbox_flicker:
		$Flicker.wait_time=hitbox_flicker
		$Flicker.timeout.connect(flicker_hitbox)
	area_entered.connect(_on_area_entered)
	disable_hitbox()

func look_target():
	if not is_instance_valid(target):
		target=null
		enable_attack()
		return
	look_at(target.global_position)
	if target is Mouse:
		if Global.load_config("game","attack_to_cursor"):
			look_at(target.global_position-Vector2.UP*16)
		else:
			look_at(targetparent.global_position+targetparent.dir)

func start_attack():
	if can_attack and buffer.is_stopped():
		started_ready.emit()
		attacking=true
		done_attacking=false
		can_attack=false
		if stop_targeting>0:
			look_target()
		if finished_time!=0:
			can_move=false
		readying=true
		delay.start()
		targettimer.start()
		
func attack():
	enable_hitbox()
	readying=false
	attacking=true
	done_attacking=false
	can_attack=false
	if finished_time!=0:
		can_move=false
	if min_attack_time>0:
		attack_timer.wait_time=randf_range(min_attack_time,attack_time)
		if parry_time>attack_time:
			parry_timer.wait_time=attack_timer.wait_time-0.01
	attack_timer.start()

func enable_hitbox():
	super.enable_hitbox()
	damaging=true
	parriable=true
	started_attack.emit()
	parry_timer.start()
	if hitbox_flicker:
		$Flicker.start()

func flicker_hitbox():
	if $Flicker.is_stopped():
		return
	if hitbox.disabled:
		look_target()
		super.enable_hitbox()
	else:
		super.disable_hitbox()

func disable_parry():
	parriable=false

func stop_attack():
	done_attacking=true
	damaging=false
	recovering=true
	if hitbox_flicker:
		$Flicker.stop()
	if finished_time!=0:
		finishedtimer.start()
	disable_hitbox()

func disable_hitbox():
	if hitbox_flicker:
		$Flicker.stop()
	super.disable_hitbox()
	can_attack=false
	ended_attack.emit()
	buffer.start()

func finish_attack():
	can_move=true
	if hitbox_flicker:
		$Flicker.stop()

func enable_attack():
	if hitbox_flicker:
		$Flicker.stop()
	disable_hitbox()
	attack_timer.stop()
	parry_timer.stop()
	buffer.stop()
	delay.stop()
	targettimer.stop()
	finishedtimer.stop()
	can_move=true
	done_attacking=true
	damaging=false
	parriable=false
	readying=false
	recovering=false
	attacking=false
	can_attack=true
	

func knockback_vector(pos):
	var vec=target.global_position-pos
	if target is Mouse:
		vec+=Vector2.DOWN*16
	return vec.normalized()*knockback
	#return Vector2.RIGHT.rotated(rotation)*knockback

func _process(_delta):
	super._process(_delta)
	if targetparent.target!=target:
		target=targetparent.target
	#if is_instance_valid(target) and can_attack:
	#	look_target()

func _on_area_entered(area):
	if monitor and is_area_hittable(area) and area.monitor:
		if area is Attack and parriable and area.parriable:
			if targetparent is Player:
				Global.hitstop(.15)
			parry.emit()
			area.parry.emit(self)
			area.disable_hitbox()
		elif area is Hurtbox:
			area.hit(self)
