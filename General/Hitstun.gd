extends Node
class_name Hitstun

@export var hurtbox: Hurtbox
@export var posture_threshold=1.0
@export var stun_time=.5
@export var combo: Combo
@export var posture_time=0
@onready var timer=$StunTimer
var stunning=false
var curr_posture=0
var posture_timer: Timer
signal stunned
signal recover

func _ready():
	curr_posture=posture_threshold
	timer.wait_time=stun_time
	if posture_time>0:
		posture_timer=$PostureTimer
		posture_timer.wait_time=posture_time
		posture_timer.timeout.connect(reset_posture)
		
	if hurtbox:
		hurtbox.take_hit.connect(stun)
	
func stun(area=null, parry=null):
	if stunning or (combo and !combo.current_attack.stunnable):
		return 
	if area:
		var posture=area.posture
		if parry:
			posture*=2 
			curr_posture-=posture
			if posture_timer:
				posture_timer.start()
				$PostureIndicator.emitting=true
		if curr_posture<=0 or posture>=posture_threshold:
			stunning=true
			reset_posture()
			stunned.emit()
			timer.start()
	if not area:
		stunning=true
		stunned.emit()
		timer.start()

func reset_posture():
	curr_posture=posture_threshold
	if posture_timer:
		$PostureIndicator.emitting=false

func stop():
	reset_posture()
	stunning=false
	recover.emit()
