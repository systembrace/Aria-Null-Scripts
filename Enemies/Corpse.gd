extends CharacterBody2D
class_name Corpse

var spawn: Vector2
var target=null
var type="enemy"
var main
var shrinking=false
var step=0
@onready var sprite=$AnimatedSprite2D
@onready var shadow=$Shadow
@onready var timer=$Timer

func _ready():
	main=get_tree().get_root().get_node("Main")
	global_position=global_position.round()
	spawn=global_position
	if randf()>.5:
		sprite.flip_h=true
	if sprite.sprite_frames.has_animation(type):
		sprite.animation=type
	var smoke=$Smoke.duplicate()
	smoke.global_position=global_position
	smoke.finished.connect(smoke.queue_free)
	get_parent().call_deferred("add_child",smoke)
	smoke.emitting=true
	$Hurtbox.take_hit.connect(die)
	timer.wait_time=randf_range(10,20)
	timer.timeout.connect(startshrink)
	timer.start()

func startshrink():
	shrinking=true
	$Hurtbox.disable_hurtbox()

func die(_area=null):
	var die_sfx=$Die.duplicate()
	main.add_child(die_sfx)
	die_sfx.finished.connect(die_sfx.queue_free)
	die_sfx.global_position=global_position
	die_sfx.play()
	var sparks=$Sparks.duplicate()
	sparks.finished.connect(sparks.queue_free)
	main.add_child(sparks)
	sparks.global_position=global_position
	sparks.emitting=true
	queue_free()

func _process(delta):
	step+=1*60*delta
	if shrinking:
		if step>=6:
			step=0
			sprite.scale=sprite.scale.move_toward(Vector2.ZERO,.25*60*delta)
			sprite.rotation=randf_range(-PI/4,PI/4)
			$Shadow.scale=Vector2(1,1)*max(sprite.scale.length()-.25,0)
	if sprite.scale.length()<=.1:
		queue_free()
