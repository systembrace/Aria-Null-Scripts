extends Breakable
class_name Chair

var just_hit=0
var friction=13
@onready var pushable=$Pushable

func _ready():
	super._ready()
	body_sprite.frame=randi_range(0,body_sprite.sprite_frames.get_frame_count(body_sprite.animation))
	pushable.call_deferred("reparent",get_tree().get_root().get_node("Main"))
	pushable.global_position=global_position
	$Hitbox.got_parried.connect(parried)

func parried(area):
	Global.hitstop(.15)
	area.parry.emit()
	hit(area)

func hit(area):
	if area.targetparent==self:
		return
	if just_hit:
		hp-=just_hit
	if area.targetparent is Player or area.targetparent is Ally or (area.targetparent is Bullet and area.targetparent.faction=="player") or area.targetparent is Harpoon:
		$Hitbox.set_collision_mask_value(1,false)
		$Hitbox.set_collision_mask_value(2,true)
		$Hitbox.set_collision_mask_value(3,false)
		$Hitbox.set_collision_mask_value(4,true)
		$Hitbox.set_collision_layer_value(3,true)
		$Hitbox.set_collision_layer_value(4,false)
		$Hurtbox.set_collision_mask_value(3,true)
		$Hurtbox.set_collision_mask_value(4,false)
	else:
		$Hitbox.set_collision_mask_value(1,false)
		$Hitbox.set_collision_mask_value(2,false)
		$Hitbox.set_collision_mask_value(3,true)
		$Hitbox.set_collision_mask_value(4,false)
		$Hitbox.set_collision_layer_value(3,false)
		$Hitbox.set_collision_layer_value(4,true)
		$Hurtbox.set_collision_mask_value(3,false)
		$Hurtbox.set_collision_mask_value(4,true)
	$Hitbox.enable_hitbox()
	just_hit=area.damage
	if area.targetparent is Bullet:
		area.targetparent.hit()
	$AnimatedSprite2D/Flash.play("hitflash")

func die():
	super.die()
	pushable.queue_free()

func _process(delta):
	if broken or !is_instance_valid(pushable):
		return
	if ((hp==1 and just_hit) or hp<=0) and pushable.linear_damp>0:
		pushable.linear_damp=0
	if ((hp==2 and just_hit) or hp<=1) and $Knockback.knockback_modifier>0:
		$Knockback.knockback_modifier=-500
	
	var lin_vel=pushable.linear_velocity
	var dest_db=min(lin_vel.length()/104*32-32,6)
	if dest_db<$Roll.db:
		$Roll.set_volume(move_toward($Roll.db,dest_db,delta*60))
	else:
		$Roll.set_volume(dest_db)
	
	if lin_vel.length()>0.5:
		if !$Roll.is_playing():
			$Roll.play(-1)
		body_sprite.speed_scale=lin_vel.length()/64
		if lin_vel.x<0:
			body_sprite.speed_scale*=-1
		body_sprite.play("default")
	elif body_sprite.is_playing():
		body_sprite.pause()
		$Roll.stop()

func _physics_process(_delta):
	if broken:
		return
	
	pushable.linear_velocity+=velocity
	global_position=round(pushable.global_transform.origin)
	velocity=Vector2.ZERO
	
	var lin_vel=pushable.linear_velocity
	if ((hp==1 and just_hit) or hp<=0) and (lin_vel.length()<0.25):
		hp-=just_hit
		die()
		return
	if lin_vel.length()<128:
		if just_hit:
			hp-=just_hit
			just_hit=0
			$Hitbox.disable_hitbox()
			$Hurtbox.set_collision_mask_value(3,true)
			$Hurtbox.set_collision_mask_value(4,true)

func pushable_body_entered(_body):
	if ((hp==1 and just_hit) or hp<=0):
		hp-=just_hit
		die()
