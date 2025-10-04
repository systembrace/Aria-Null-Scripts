extends Attack
class_name BackstepAttack

@export var numshots=12
@export var dash: Dash

func can_use():
	return can_attack

func use():
	get_parent().attack_index(combo_index)

func attack():
	super.attack()
	dash.dir=-Vector2.RIGHT.rotated(global_rotation)
	dash.start_dash()
