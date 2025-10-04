extends Area2D
class_name ParryChecker

@export var hitbox: Attack
@export var stun: Hitstun
@onready var delay=$Delay
@onready var parry=$Parry
@onready var buffer=$Buffer
var can_try=true
var monitor=true

func _ready():
	delay.wait_time=hitbox.delay_time
	delay.timeout.connect(enable_parry)
	parry.wait_time=hitbox.parry_time
	parry.timeout.connect(disable_parry)
	buffer.wait_time=hitbox.attack_time+hitbox.buffer_time
	buffer.timeout.connect(enable_try)
	$CollisionShape2D.disabled=true
	area_entered.connect(hit_connected)
	
func try_parry():
	if can_try:
		can_try=false
		delay.start()
	
func enable_parry():
	$CollisionShape2D.set_deferred("disabled",false)
	monitor=true
	parry.start()
	buffer.start()
	
func disable_parry():
	$CollisionShape2D.set_deferred("disabled",true)
	monitor=false
	
func enable_try():
	can_try=true
	
func hit_connected(area):
	if area is Attack:
		disable_parry()
		stun.stop()
		hitbox.enable_attack()
		hitbox.get_parent().stun_counterattack(area)
