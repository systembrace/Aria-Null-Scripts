extends AnimatedSprite2D

@export var combo:Combo
@export var shoot_state: RangedState
var slowdown_entered=false

func _ready():
	visible=false

func _process(_delta):
	if slowdown_entered and (Input.is_action_just_released("attack") or !visible):
		Global.slow_down_to_zero=false
		Global.slow_down_speed=1
	elif slowdown_entered and Engine.time_scale==1:
		slowdown_entered=false
	if combo:
		if combo.is_parriable():
			visible=true
			animation="on"
		elif combo.is_damaging():
			visible=true
			animation="unparriable"
		elif not combo.can_move():
			visible=true
			animation="off"
			var target=combo.current_attack.target
			if target is Player:
				var targetdist=combo.to_local(target.global_position).length()
				if not Global.get_permanent_data("global","has_parried") and !slowdown_entered and targetdist<112:
					target.control.parry_moment=true
					slowdown_entered=true
					Global.slow_down_to_zero=true
					Global.slow_down_speed=3.1+(targetdist-72)/144
		else:
			visible=false
	if shoot_state and shoot_state.delay:
			if !shoot_state.delay.is_stopped():
				visible=true
				animation="off"
			elif shoot_state.gun.firing:
				visible=true
				animation="on"
			else:
				visible=false
