extends Entity
class_name Breakable

@export var hp=1
@export var shake=false
signal broke
var broken=false

func _ready():
	if broken:
		return
	super._ready()
	$Hurtbox.take_hit.connect(hit)

func set_broken():
	broken=true
	free_children()

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

func free_children():
	for child in get_children():
		if child is TileSwapper:
			child.call_deferred("swap",true)
		child.queue_free()

func die():
	if broken:
		return
	broken=true
	broke.emit()
	for status in status_effects:
		if is_instance_valid(status):
			remove_status_effect(status)
	if shake:
		Global.screenshake(.05)
	
	$PartSpawner.spawn()
	$Die.play()
	$Die.reparent(get_parent())
	$DustPuff.global_rotation=0
	$DustPuff.emitting=true
	$DustPuff.reparent(get_parent())
	free_children()
