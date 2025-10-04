extends Area2D

@onready var body = get_parent()
@onready var sand = $Sand

func _process(delta):
	if sand.emitting:
		position=-body.velocity*delta*2
		sand.amount_ratio=min(body.velocity.length()/body.max_speed+.2,1)
	if not sand.emitting and get_overlapping_bodies() and body.velocity.length()>.01:
		sand.emitting=true
	elif sand.emitting and not (get_overlapping_bodies() and body.velocity.length()>.01):
		sand.emitting=false
