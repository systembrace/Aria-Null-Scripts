extends Node2D

@export var hitbox_time=.32
@export var damage=2
@export var player_damage=0
var smalls=[]
@onready var basesmall=$BaseSmall
@onready var timer=$Timer
@onready var hitboxtimer=$HitboxTimer

func _ready():
	Global.screenshake(.2,2)
	$SFX.play()
	$Sprite.play()
	$Ring.emitting=true
	$Sparks.emitting=true
	$DustPuff.emitting=true
	$DustPuff.global_position=global_position
	$DustPuff.reparent(get_parent())
	$CustomParticleSpawner.spawn(false,global_position,1.5)
	for i in range(0,16):
		var small=basesmall.duplicate()
		small.position=Vector2.UP.rotated(i*PI/8)*(20+(i%2)*6)+Vector2.UP*((i+1)%2)*4
		add_child(small)
		small.visible=true
		smalls.insert(randi_range(0,len(smalls)),small)
	timer.wait_time=1
	timer.timeout.connect(queue_free)
	timer.start()
	hitboxtimer.wait_time=hitbox_time
	hitboxtimer.timeout.connect($Hitbox.disable_hitbox)
	hitboxtimer.start()
	$Hitbox.damage=damage
	$Hitbox.player_damage=player_damage
	$Hitbox.enable_hitbox()

func _process(delta):
	if not smalls.is_empty() and not smalls[0].is_playing() and randf()>.05/(60*delta):
		smalls[0].play()
		smalls.remove_at(0)
	elif smalls.is_empty():
		$Circle.visible=false
