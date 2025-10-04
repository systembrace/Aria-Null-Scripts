extends AnimatedSprite2D

@export var combo:Combo
@export var shoot_state: RangedState

func _ready():
	visible=false

func _process(_delta):
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
