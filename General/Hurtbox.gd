extends Area2D
class_name Hurtbox

signal take_hit(area)
signal hurtboxenabled
@export var invincibility_time=0.0
@export var parent_combo: Combo
@export var has_hitbuffer=false
@export var always_hittable=false
@onready var timer=$IFrames
@onready var hitbuffer=find_child("HitBuffer")
@onready var hurtbox=$CollisionShape2D
var attack: Hitbox
var monitor=true
var add_damage=0

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
		take_hit.emit(parry, true)
	disable_hurtbox()
	timer.start()

func get_hit():
	if attack and (!attack.targetparent is Harpoon or attack.targetparent.previous_enemy!=get_parent()):
		if parent_combo and parent_combo.current_attack.interruptible:
			parent_combo.disable_hitbox()
		attack.hit_hurtbox.emit(get_parent())
		take_hit.emit(attack)
		if invincibility_time!=0:
			disable_hurtbox()
			timer.start()
	if has_hitbuffer:
		hitbuffer.stop()

func fall():
	attack=null
	if parent_combo:
		parent_combo.disable_hitbox()
	var fall_hitbox=Hitbox.new()
	fall_hitbox.targetparent=self
	take_hit.emit(fall_hitbox)
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
