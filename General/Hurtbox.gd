extends Area2D
class_name Hurtbox

signal take_hit(area)
signal hurtboxenabled
@export var invincibility_time=0.0
@export var parent_combo: Combo
@export var has_hitbuffer=false
@export var hitstop=0.0
@export var always_hittable=false
@onready var timer=$IFrames
@onready var hitbuffer=find_child("HitBuffer")
@onready var hurtbox=$CollisionShape2D
var attack: Hitbox
var monitor=true
var add_damage=0
var allow_melee_attacks=true

func _ready():
	area_entered.connect(hit)
	if parent_combo:
		parent_combo.parry.connect(cancel_damage)
	if invincibility_time!=0:
		timer.wait_time=invincibility_time
	else:
		timer.wait_time=.12
	timer.timeout.connect(enable_hurtbox)
	if has_hitbuffer:
		hitbuffer.wait_time=.05
		hitbuffer.timeout.connect(get_hit)

func cancel_damage(parry=null):
	if parry is Bullet or parry is Harpoon:
		return
	attack=null
	if parry:
		take_hit.emit(parry, parent_combo.current_attack)
	disable_hurtbox()
	timer.start()

func get_hit():
	if attack is Attack and parent_combo and !parent_combo.current_attack.allow_melee_attacks_while_damaging and parent_combo.is_parriable():
		return
	if attack and (!attack.targetparent is Harpoon or attack.targetparent.previous_enemy!=get_parent()):
		if attack is Attack and attack.stop_on_hit and attack.targetparent.target==get_parent():
			attack.stop_attack()
		if parent_combo and parent_combo.current_attack.interruptible:
			parent_combo.disable_hitbox()
		attack.hit_hurtbox.emit(get_parent())
		take_hit.emit(attack)
		if hitstop>0 and attack.targetparent is Player:
			Global.hitstop(hitstop)
		if invincibility_time!=0:
			disable_hurtbox()
			timer.start()
	if has_hitbuffer:
		hitbuffer.stop()

func take_non_attack_damage(hitbox_type="Fall"):
	attack=null
	if parent_combo:
		parent_combo.disable_hitbox()
	var new_hitbox=Hitbox.new()
	new_hitbox.name=hitbox_type
	new_hitbox.targetparent=self
	take_hit.emit(new_hitbox)
	new_hitbox.free()
	if invincibility_time!=0:
		disable_hurtbox()
		timer.start()
	if has_hitbuffer:
		hitbuffer.stop()

func enable_hurtbox():
	if invincibility_time!=0 and !timer.is_stopped():
		return
	hurtbox.set_deferred("disabled",false)
	monitor=true
	hurtboxenabled.emit()

func disable_hurtbox():
	hurtbox.set_deferred("disabled",true)
	monitor=false

func hit(area):
	if area is Hitbox and area.monitor and monitor:
		attack=area
		if area is Attack and parent_combo and has_hitbuffer:
			hitbuffer.start()
			return
		elif not area is Attack and invincibility_time!=0:
			disable_hurtbox()
			timer.start()
		get_hit()
