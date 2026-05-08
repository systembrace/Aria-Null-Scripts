extends Entity
class_name Breakable

@export var hp=1
var broken=false

func _ready():
	super._ready()
	$Hurtbox.take_hit.connect(hit)

func set_broken():
	broken=true
	for child in get_children():
		child.queue_free()

func hit(area):
	hp-=area.damage
	if area.targetparent is Bullet and not area.targetparent is Harpoon:
		area.targetparent.hit()
	for child in get_children():
		if child is Pseudo3DSprite:
			child.find_child("Flash").stop()
			child.find_child("Flash").play("hitflash")
	if hp<=0:
		die()

func die():
	if broken:
		return
	broken=true
	
	for status in status_effects:
		if is_instance_valid(status):
			remove_status_effect(status)
	
	$PartSpawner.spawn()
	$Die.play()
	$Die.reparent(get_parent())
	$DustPuff.global_rotation=0
	$DustPuff.emitting=true
	$DustPuff.reparent(get_parent())
	for child in get_children():
		child.queue_free()
		if child is TileSwapper:
			child.swap(true)
