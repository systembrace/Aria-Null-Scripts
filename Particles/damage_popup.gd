extends Node2D
class_name DamagePopup

var damage=1
var speed=32
func _ready():
	$Label.text=str(damage)
	modulate.a=min(0.5*damage,1)
	$Timer.wait_time=min(0.5*damage,3)
	$Timer.timeout.connect(queue_free)
	$Timer.start()
	speed/=damage

func _physics_process(delta):
	global_position+=Vector2.UP*speed*delta
