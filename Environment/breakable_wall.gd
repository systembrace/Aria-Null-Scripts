extends CharacterBody2D
class_name BreakableWall

@export var hp=3
signal broke
@onready var health=$Health
@onready var tilemap=$TileMap

func _ready():
	health.set_max(hp)
	health.took_damage.connect(shake)
	health.dead.connect(die)
	
func shake():
	tilemap.position=Vector2.RIGHT.rotated(randf_range(0,2*PI))*randi_range(6,8)
	$Hit.play()

func die():
	$PartSpawner.spawn()
	$DustPuff.emitting=true
	$DustPuff.reparent(get_parent())
	$Break.play()
	$Break.reparent(get_parent())
	broke.emit()
	queue_free()

func _process(_delta):
	if tilemap.position.length()>.5:
		tilemap.position=lerp(tilemap.position,Vector2.ZERO,1.5)
	elif tilemap.position!=Vector2.ZERO:
		tilemap.position=Vector2.ZERO
