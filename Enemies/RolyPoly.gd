extends Enemy
class_name RolyPoly

@export var hitbox: Hitbox
@export var sprite: AnimationController
@export var bounce_amount=0.9
@export var charge_attack:Attack
@export var bounce_ds=3.0
@export var gravity=30
signal bounced
var dh=0
@onready var trail=$AnimationController/AnimatedSprite2D/Trail

func _ready():
	super._ready() 
	$Health.took_damage.connect(hit)
	trail.clear_points()
	trail.add_point(Vector2.ZERO)
	trail.add_point(Vector2.ZERO)
	if control.explode_on_death:
		hitbox.hit_hurtbox.connect(control.die.unbind(1))

func hit(area=null):
	if $Health.hp>0 or (area and area.destructive and area.targetparent is RolyPoly):
		return
	hurtbox.set_collision_layer_value(2,false)
	if hitbox:
		hitbox.set_collision_layer_value(4,false)
		hitbox.set_collision_layer_value(3,true)
		hitbox.set_collision_mask_value(2,true)
		hitbox.set_collision_mask_value(5,true)
		if !hitbox.monitor:
			hitbox.enable_hitbox()
	#get_tree().create_timer(0.5,false).timeout.connect(reenable)

func reenable():
	hurtbox.set_collision_layer_value(2,true)
	if hitbox:
		hitbox.set_collision_layer_value(4,true)
		hitbox.set_collision_layer_value(3,false)
		hitbox.set_collision_mask_value(2,false)
		hitbox.set_collision_mask_value(5,true)

func bounce(amt=0.0):
	if velocity.length()<128 or (amt==0 and bounce_ds==0):
		return
	if amt==0:
		amt=bounce_ds
	dh=min(amt*velocity.length()/max_speed,amt)
	if sprite and sprite.position.y!=0:
		dh*=(64-min(abs(sprite.position.y),64))/64
	
func _physics_process(delta):
	entity_physics_process(delta)
	$Roll.play()
	$Roll.set_volume(min(-(max_speed-velocity.length())/max_speed*30,0))
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
		var new_vel=velocity.bounce(coll.get_normal())*bounce_amount
		set_deferred("velocity",new_vel)
		if charge_attack:
			charge_attack.call_deferred("look_at",new_vel)
		bounced.emit()
	var prev=trail.global_position
	move_and_slide()
	if sprite:
		sprite.position.y-=dh
		if int(sprite.position.y)<0:
			dh-=gravity*delta
		else:
			dh=0
			sprite.position.y=0
	trail.remove_point(1)
	trail.add_point(trail.to_local(prev)*8)
