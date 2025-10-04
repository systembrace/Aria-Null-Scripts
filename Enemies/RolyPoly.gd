extends Enemy
class_name RolyPoly

@export var hitbox: Hitbox
@export var sprite: AnimatedSprite2D
var dh=0
var gravity=30
@onready var trail=$AnimationController/AnimatedSprite2D/Trail

func _ready():
	super._ready() 
	$Health.dead.connect(die)
	trail.clear_points()
	trail.add_point(Vector2.ZERO)
	trail.add_point(Vector2.ZERO)

func die(_area=null):
	hurtbox.set_collision_layer_value(2,false)
	hitbox.set_collision_layer_value(4,false)
	hitbox.set_collision_layer_value(3,true)
	hitbox.set_collision_mask_value(2,true)
	hitbox.set_collision_mask_value(5,true)

func bounce():
	if velocity.length()<128:
		return
	dh=min(3*velocity.length()/max_speed,3)
	if sprite.position.y!=0:
		dh*=(64-min(abs(sprite.position.y),64))/64
	
func _physics_process(delta):
	entity_physics_process(delta)
	$Roll.play()
	$Roll.setVolume(min(-(max_speed-velocity.length())/max_speed*30,0))
	var chance=0
	if $Chirp.is_playing():
		chance=2
	if randf()<chance/60.0:
		$Chirp.play()
	var coll=move_and_collide(velocity*delta,true)
	if coll:
		$Chirp.play()
		$Bounce.play()
		bounce()
		set_deferred("velocity",velocity.bounce(coll.get_normal())*.9)
	var prev=trail.global_position
	move_and_slide()
	sprite.position.y-=dh
	if int(sprite.position.y)<0:
		dh-=gravity*delta
	else:
		dh=0
		sprite.position.y=0
	trail.remove_point(1)
	trail.add_point(trail.to_local(prev)*8)
