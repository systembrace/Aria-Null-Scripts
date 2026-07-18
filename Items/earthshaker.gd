extends Entity
class_name Earthshaker

var dir=Vector2.RIGHT
var dh=0
var gravity=8
var deploying=true
var waiting=false
var charged=false
var main_charged=false
var init_speed=18
var step=0
var activations=0
@onready var hitbox=$Hitbox
@onready var particles=$Particles
@onready var part_spawner=$Particles/PartSpawner
@onready var sprite=$Sprite
@onready var wave=$Wave
@onready var coll1=$Hitbox/CollisionShape2D1
@onready var coll2=$Hitbox/CollisionShape2D2
@onready var coll3=$Hitbox/CollisionShape2D3
@onready var timer=$Timer

func _ready():
	super._ready()
	if charged:
		hitbox.damage=1
		if !main_charged:
			sprite.visible=false
			$Shadow.queue_free()
	if !charged or main_charged:
		sprite.flip_h=randi_range(0,1)
		$Throw.play()
	coll1.shape=coll1.shape.duplicate()
	coll2.shape=coll2.shape.duplicate()
	coll2.shape=coll3.shape.duplicate()
	wave.rotation=dir.angle()
	particles.process_material.emission_sphere_radius=10
	$Hitbox.rotation=dir.angle()
	particles.finished.connect(reset_particles)
	remove_child(particles)
	get_tree().get_root().get_node("Main").add_child(particles)
	timer.wait_time=1.5
	if charged:
		timer.wait_time=2.5
	timer.timeout.connect(attack)

func attack():
	sprite.animation="emit"
	sprite.play()
	wave.visible=true
	hitbox.enable_hitbox()
	if !charged or main_charged:
		$SFX.play()
	waiting=false
	activations+=1
	particles.global_position=global_position+dir*8

func reset():
	hitbox.disable_hitbox()
	coll1.shape.radius=12
	coll2.shape.radius=8
	coll3.shape.radius=8
	coll1.position=Vector2.ZERO
	coll2.position=Vector2.ZERO
	coll3.position=Vector2.ZERO
	wave.visible=false
	wave.scale=Vector2(0.1,0.1)
	wave.position=Vector2(0,0)
	waiting=true

func reset_particles():
	particles.emitting=false
	particles.process_material.emission_sphere_radius=10
	particles.global_position=global_position

func _process(delta):
	step+=1*60*delta
	if not falling and not on_floor and sprite.position.y>=0:
		fall()

func _physics_process(delta):
	super._physics_process(delta)
	move_and_slide()
	if waiting:
		return
	if deploying:
		dh+=gravity*delta
		sprite.position.y+=dh
		if sprite.position.y>=0 and on_floor:
			global_position=global_position.round()
			sprite.position.y=0
			velocity=Vector2.ZERO
			deploying=false
			timer.start()
			attack()
		return
	if !particles.emitting:
		particles.emitting=true
	var speed=init_speed*60*delta
	if coll1.position.x<16:
		coll1.position.x=16
		coll2.position.x+=speed
		coll3.position.x+=speed
	elif coll2.position.x<32:
		if coll2.shape.radius<14:
			coll2.shape.radius+=3
		particles.process_material.emission_sphere_radius=14
		coll2.position.x+=speed/2
		coll3.position.x+=speed/2
	elif coll3.position.x<72:
		if coll3.shape.radius<26:
			coll3.shape.radius+=3
		particles.process_material.emission_sphere_radius=20
		coll3.position.x+=speed/4
	else:
		reset()
		if activations>=3:
			timer.stop()
			sprite.animation="dead"
	particles.global_position+=dir*speed/3.5
	if randf()<0.25:
		part_spawner.spawn()
	if wave.scale.x!=1:
		wave.scale=wave.scale.move_toward(Vector2(1,1),.2)
	wave.global_position=particles.global_position+dir*16
	Global.screenshake()
