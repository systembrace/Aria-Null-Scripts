extends Node
class_name Hitstun

@export var hurtbox: Hurtbox
@export var posture_threshold=1.0
@export var stun_time=.5
@export var combo: Combo
@onready var timer=$StunTimer
var stunning=false
var curr_posture=0
signal stunned
signal recover

func _ready():
	curr_posture=posture_threshold
	timer.wait_time=stun_time
	if hurtbox:
		hurtbox.take_hit.connect(stun)
	
func stun(area=null, parry=null):
	if stunning or (combo and !combo.current_attack.interruptible):
		return 
	if area:
		var posture=area.posture
		if parry:
			posture*=2 
			curr_posture-=posture
		if curr_posture<=0 or posture>=posture_threshold:
			curr_posture=posture_threshold
			stunning=true
			stunned.emit()
			timer.start()
	if not area:
		stunning=true
		stunned.emit()
		timer.start()

func stop():
	stunning=false
	recover.emit()
