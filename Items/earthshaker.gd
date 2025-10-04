extends Entity
class_name Earthshaker

var dir=Vector2.RIGHT
var dh=0
var gravity=8
var deploying=true
var done=false
var fading=false
var charged=false
var init_speed=18
var step=0
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
		sprite.visible=false
		$Shadow.visible=false
	else:
		sprite.flip_h=randi_range(0,1)
		$Throw.play()
	wave.rotation=dir.angle()
	particles.process_material.emission_sphere_radius=10
	$Hitbox.rotation=dir.angle()
	particles.finished.connect(particles.queue_free)
	remove_child(particles)
	get_tree().get_root().get_node("Main").add_child(particles)
	timer.wait_time=randf_range(10,20)
	timer.timeout.connect(set_deferred.bind("fading",true))

func _process(delta):
	step+=1*60*delta
	if fading:
		if step>=6:
			step=0
			sprite.scale=sprite.scale.move_toward(Vector2.ZERO,.25*60*delta)
			sprite.rotation=randf_range(-PI/4,PI/4)
			$Shadow.scale=Vector2(1,1)*max(sprite.scale.length()-.25,0)
	if sprite.scale.length()<=.1:
		queue_free()
	if not falling and not on_floor and sprite.position.y>=0:
		fall()

func _physics_process(delta):
	super._physics_process(delta)
	move_and_slide()
	if done:
		return
	if deploying:
		dh+=gravity*delta
		sprite.position.y+=dh
		if sprite.position.y>=0 and on_floor:
			sprite.position.y=0
			particles.global_position=global_position+dir*8
			velocity=Vector2.ZERO
			deploying=false
			sprite.play()
			wave.visible=true
			hitbox.enable_hitbox()
			if !charged:
				$SFX.play()
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
		hitbox.queue_free()
		wave.visible=false
		done=true
		timer.start()
	particles.global_position+=dir*speed/3.5
	part_spawner.spawn()
	if wave.scale.x!=1:
		wave.scale=wave.scale.move_toward(Vector2(1,1),.2)
	wave.global_position=particles.global_position+dir*16
	Global.screenshake()
