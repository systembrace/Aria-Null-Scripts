extends CharacterBody2D
class_name Box

var broken=false

func _ready():
	$Area2D.area_entered.connect(die)

func set_broken():
	broken=true
	for child in get_children():
		child.queue_free()

func die(area):
	if broken:
		return
	broken=true
	if area.targetparent is Bullet:
		area.targetparent.hit()
	
	$PartSpawner.spawn()
	$Die.play()
	$Die.reparent(get_parent())
	$DustPuff.emitting=true
	$DustPuff.reparent(get_parent())
	for child in get_children():
		child.queue_free()
