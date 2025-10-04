extends Attack

@onready var rubble=$Rubble
var main

func _ready():
	main=get_tree().get_root().get_node("Main")
	super._ready()

func attack():
	super.attack()
	rubble.spawn()
	var dust=$Dust.duplicate()
	main.add_child(dust)
	dust.global_position=global_position
	dust.emitting=true
	dust.finished.connect(dust.queue_free)
