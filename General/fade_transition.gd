extends Sprite2D
class_name FadeTransition

@export var main_transition=true
@export var area:Area2D
signal finished
signal faded_out
var fade=false
var lerp_to=0.0
var speed=.25
var finished_emitted=false

func _ready():
	modulate.a=1
	if main_transition:
		var timer=get_tree().create_timer(.5)
		timer.timeout.connect(fade_out)
		scale=Vector2(480,270)
	else:
		add_to_group("objs_to_load")
		area.set_collision_layer_value(1,false)
		area.set_collision_mask_value(1,false)
		area.set_collision_mask_value(17,true)
		area.body_entered.connect(fade_out.unbind(1))
		area.body_entered.connect(play_discover.unbind(1))
	
func fade_out(seconds=.25):
	speed=seconds
	fade=true
	finished_emitted=false
	lerp_to=0.0
	
func play_discover():
	var main=get_tree().get_root().get_node("Main")
	var sfx=find_child("Discover")
	if !sfx:
		return
	sfx.reparent(main)
	sfx.play()

func reverse_fade(seconds=.1):
	speed=seconds
	fade=true
	finished_emitted=false
	lerp_to=1.0

func _process(delta):
	if !fade:
		return
	if !finished_emitted and modulate.a>lerp_to and modulate.a<.5:
		finished.emit()
		finished_emitted=true
	if abs(modulate.a-lerp_to)<.02:
		modulate.a=lerp_to
		fade=false
		if !main_transition:
			queue_free()
		if lerp_to==1.0:
			faded_out.emit()
		return
	modulate.a=move_toward(modulate.a,lerp_to,delta/speed)
