extends AnimatedSprite2D

var fade=false
var crack=false
@onready var timer=$Timer

func _ready():
	visible=false
	frame=randi_range(0,sprite_frames.get_frame_count("default"))
	if !crack:
		offset+=Vector2.UP*randi_range(-10,0)
	timer.wait_time=randf_range(10,20)
	if crack:
		timer.wait_time=4
	timer.timeout.connect(start_fade)
	timer.start()
	global_position=round(global_position)
	if crack:
		animation="crack"

func start_fade():
	fade=true
	
func _physics_process(_delta):
	if not visible and $Left.has_overlapping_bodies() and $Right.has_overlapping_bodies():
		visible=true
		$Left.free()
		$Right.free()
		#global_position.y+=8
	elif not visible:
		queue_free()
		return
	if fade:
		modulate.a=move_toward(modulate.a,0,.005)
	if modulate.a==0:
		queue_free()
