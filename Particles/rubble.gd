extends Gib
class_name Rubble

var vel_mod=1
var step2=0

func _ready():
	super._ready()
	if !Global.can_create_particle():
		return
	dh=randf_range(4,6)*vel_mod
	bounce=(dh-4)*.01+.1
	velocity=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*randf_range(96,128)*vel_mod
	timer.wait_time=randf_range(3,6)
	
func _process(delta):
	super._process(delta)
	if shrink:
		$Shadow.scale=Vector2(.75,.75)*clamp(sprite.scale.length(),0,1)
	if settled:
		return
	step2+=delta*60
	if int(step2)%4==0 and timer.is_stopped() and not shrink and delta>1/240:
		sprite.rotation=randf_range(0,2*PI)
