extends Secondary
class_name Gun

@export var gun_name="pistol"
@export var buffertime=.15
@export var standtime=.2
@export var damage:float=1
@export var bullet_speed=384
@export var speed_mod=0
@export var bullets_per_shot=1
@export var spread=0
@export var bullet_size=1.0
@export var bullet_knockback=100
@export var shot_volume=0.0
@export var always_show=false
#@export var phase_in=false
@export var alt_target: Node2D
@export var force_alt_target=false
@export var cloak=false
@export var bullet_height=19.0
@export var offset=Vector2(0,-5)
var readying=false
var firing=false
var shooting=false
var dir=Vector2.RIGHT
var length=0
var angle_offset=0
var override_pos=Vector2.ZERO
var main: Node2D
@onready var buffer=$BufferTimer
@onready var stand=$StandTimer
@onready var sprite=$Sprite
@onready var flash=$Sprite/Flash

func _ready():
	main=get_tree().get_root().get_node("Main")
	buffer.wait_time=buffertime
	buffer.timeout.connect(set.bind("firing",false))
	stand.wait_time=standtime
	stand.timeout.connect(allow_move)
	sprite.animation=gun_name
	sprite.offset=offset
	length=sprite.sprite_frames.get_frame_texture(gun_name,0).get_width()
	var soundname=gun_name
	if "cherry_" in gun_name:
		soundname=gun_name.substr(gun_name.find("_")+1)
	$Sprite/Gunshot.db=shot_volume
	$Sprite/Gunshot/SFX.stream=load("res://assets/SFX/"+soundname+".wav")

func equip(parent):
	super.equip(parent)
	if not targetparent is Player and not targetparent is Ally:
		$Sprite/Flash/Light.color="f23084"
		if flash is AnimatedSprite2D:
			flash.animation="enemy"

func show_flash():
	flash.visible=true
	flash.rotation=randf()*PI/2
	flash.position.x=length+1
	flash.position.y=-1
	var timer = get_tree().create_timer(.05)
	timer.timeout.connect(disable_flash)

func updatesprite():
	dir=target_dir(override_pos, angle_offset)
	
	sprite.flip_v=false
	sprite.z_index=1
	if cloak:
		$Cloak.visible=false
	sprite.position.x=0
	sprite.rotation=dir.angle()
	if abs(dir.angle_to(Vector2.UP))<PI/4:
		sprite.animation=gun_name+"_up"
		sprite.z_index=0
	elif abs(dir.angle_to(Vector2.DOWN))<PI/4:
		sprite.animation=gun_name+"_down"
		if cloak and dir.x>0:
			$Cloak.visible=true
	else:
		sprite.animation=gun_name
		if dir.x<0:
			sprite.flip_v=true
			sprite.position.x=-1
			flash.position.x=length
			flash.position.y=1
		else:
			sprite.position.x=2
	#if !sprite.visible and phase_in:
	#	$Sprite/PhaseIn.play("phase_in")
	sprite.visible=true

func can_use():
	return not firing

func use():
	shoot()

func make_bullet():
	var bullet=load("res://Scenes/General/bullet.tscn").instantiate()
	main.call_deferred("add_child",bullet)
	bullet.dir=target_dir(override_pos,angle_offset)
	bullet.speed=bullet_speed+randi_range(-speed_mod,speed_mod)
	bullet.damage=damage
	bullet.size=bullet_size
	bullet.knockback=bullet_knockback
	bullet.global_position=targetparent.global_position+bullet.dir*(length+4)+Vector2.UP*(bullet_height-19)
	bullet.dir=bullet.dir.rotated(randf_range(-spread/180.0*PI,spread/180.0*PI))
	if targetparent is Player or targetparent is Ally:
		bullet.faction="player"

func shoot(override=Vector2.ZERO):
	if !is_instance_valid(target) or firing:
		return
	if override!=Vector2.ZERO:
		override_pos=override
	if main.dark:
		$Sprite/Flash/Light.enabled=true
	else:
		$Sprite/Flash/Light.enabled=false
	$Sprite/Gunshot.play()
	firing=true
	cant_move=true
	for i in range(0,bullets_per_shot):
		make_bullet()
	show_flash()
	updatesprite()
	shooting=true
	buffer.start()
	stand.start()
	override_pos=Vector2.ZERO

func cancel_shot():
	disable_flash()
	hide_sprite()
	allow_move()
	stand.stop()
	buffer.start()

func disable_flash():
	flash.visible=false
	$Sprite/Flash/Light.enabled=false

func hide_sprite():
	shooting=false
	sprite.visible=false
	if cloak:
		$Cloak.visible=false

func allow_move():
	cant_move=false
	if !always_show:
		hide_sprite()

func _process(_delta):
	if !targetparent:
		return
	if target!=targetparent.target:
		target=targetparent.target
	if alt_target:
		if !is_instance_valid(target) or force_alt_target:
			override_pos=alt_target.global_position
		else:
			override_pos=Vector2.ZERO
	if always_show and (shooting or readying):
		updatesprite()
	if !is_instance_valid(target) and !always_show:
		hide_sprite()
