extends Area2D
class_name Hitbox

@export var targetparent:Node2D
@export var damage=1.0
@export var base_posture=1.0
@export var base_knockback=0
@export var player_damage=0
@export var start_enabled=false
@export var always_hittable=false
var posture=base_posture
var knockback=base_knockback
var monitor=true
signal got_parried
signal hit_hurtbox
signal hit_something
@onready var hitbox=$CollisionShape2D

func _ready():
	area_entered.connect(_on_area_entered)
	if not start_enabled:
		disable_hitbox()
	else:
		enable_hitbox()

func knockback_vector(pos):
	return targetparent.to_local(pos).normalized()*knockback

func enable_hitbox():
	hitbox.set_deferred("disabled",false)
	monitor=true
	
func disable_hitbox():
	hitbox.set_deferred("disabled",true)
	monitor=false

func is_area_hittable(area):
	if area.always_hittable:
		return true
	var ray = RayCast2D.new()
	get_parent().add_child(ray)
	ray.global_position=global_position
	ray.set_collision_mask_value(1,false)
	ray.set_collision_mask_value(10,true)
	ray.target_position=area.global_position-global_position
	ray.force_raycast_update()
	if ray.is_colliding():
		return false
	return true

func _process(_delta):
	posture=base_posture
	knockback=base_knockback

func _on_area_entered(area):
	if monitor and is_area_hittable(area) and area.monitor:
		if area is Hurtbox:
			if player_damage>0 and area.get_parent() is Player or area.get_parent() is Ally:
				var temp=damage
				damage=player_damage
				area.hit(self)
				damage=temp
				return
			area.hit(self)
		elif area is Attack:
			got_parried.emit(area)
		elif area is Hitbox:
			hit_something.emit(area)
