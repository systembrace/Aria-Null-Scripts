extends Area2D

@export var control: PlayerControl
@onready var timer=$Timer
var corpse:Area2D

func _ready():
	timer.wait_time=3
	timer.timeout.connect(finish_repair)

func _process(_delta):
	if not control.stunned and Input.is_action_pressed("interact") and has_overlapping_areas():
		for area in get_overlapping_areas():
			if area is PlayerCorpse and timer.is_stopped():
				timer.start()
				corpse=area
	elif not timer.is_stopped():
		corpse=null
		timer.stop()
		
func finish_repair():
	if is_instance_valid(corpse) and not control.stunned:
		corpse.revive()
		$CustomParticleSpawner.spawn()
		var play_sound=$DestroyCorpse.duplicate()
		play_sound.connect("finished",play_sound.queue_free)
		var main=get_tree().get_root().get_node("Main")
		main.add_child(play_sound)
		play_sound.play()
		get_parent().queue_free()
