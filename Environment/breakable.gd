extends CharacterBody2D
class_name Box

var dead=false

func _ready():
	$Area2D.area_entered.connect(die)

func die(area):
	if dead:
		return
	dead=true
	if area.targetparent is Bullet:
		area.targetparent.hit()
	
	$PartSpawner.spawn()
	$Die.play()
	$Die.reparent(get_parent())
	$DustPuff.emitting=true
	$DustPuff.reparent(get_parent())
	queue_free()
