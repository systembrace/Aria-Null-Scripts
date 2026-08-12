extends Area2D
class_name RolyDoor

@export var big_roly=false
@export var stay=false
@export var is_open=false
@export var block_player_if_big=true
var staticbody: StaticBody2D
@onready var sprite=$LockRotation/Pseudo3DSprite

func _ready():
	if big_roly:
		staticbody=$StaticBody2D
		if block_player_if_big:
			staticbody.set_collision_layer_value(28,true)
	if is_open:
		open()
	$Timer.timeout.connect(close)

func open():
	sprite.frame=1
	is_open=true
	if big_roly:
		staticbody.set_collision_layer_value(10,false)
		staticbody.set_collision_layer_value(15,false)
		$StaticBody2D/CollisionShape2D.swap(true)

func close():
	sprite.frame=0
	is_open=false
	if big_roly:
		staticbody.set_collision_layer_value(10,true)
		staticbody.set_collision_layer_value(15,true)
		$StaticBody2D/CollisionShape2D.swap(false)

func _process(_delta):
	if stay:
		if has_overlapping_bodies():
			for body in get_overlapping_bodies():
				if body is Player:
					open()
					$Timer.start()
					break
		return
	if !is_open and has_overlapping_bodies():
		open()
		$Timer.stop()
	elif $Timer.is_stopped():
		$Timer.start()
