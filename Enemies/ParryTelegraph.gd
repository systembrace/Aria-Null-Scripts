extends AnimatedSprite2D

@export var combo:Combo
@export var shoot_state: RangedState
var slowdown_entered=false

func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	visible=false

func _process(_delta):
	if slowdown_entered:
		var target=combo.current_attack.target
		if Engine.time_scale==1 or (!visible and target is Player and target.control.parry_moment):
			get_tree().create_timer(1,false,false,true).timeout.connect(set.bind("slowdown_entered",false))
			Global.slow_down_to_zero=false
			Global.slow_down_speed=1
			target.control.parry_moment=false
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
			if not Global.get_permanent_data("global","has_parried") and !slowdown_entered and is_instance_valid(target) and target is Player and target.original_player and !Global.slow_down_to_zero and Engine.time_scale==1 and !target.control.parry_moment:
				var targetdist=combo.to_local(target.global_position).length()
				if targetdist<112:
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
