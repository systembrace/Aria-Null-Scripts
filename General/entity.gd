extends CharacterBody2D
class_name Entity

@export var heavy=false
@export var player_hurtbox:Hurtbox
@export var respawn_on_fall=false
@export var can_jump=false
@export var size=1.0
@export var grappleable=false
signal started_falling
signal fell
var initial_fall_buffer=true
var status_effects=[]
var prev_location=global_position
var floor_checker
var landing_checker
var coyote
var fall_timer
var on_floor=true
var falling=false
var body_dh=0
var body_sprite
var body_sprite_y_offset=0
var jumping=false
var enable_edges=false
var hurtbox:Hurtbox

func _ready():
	hurtbox=find_child("Hurtbox")
	body_sprite=find_child("AnimatedSprite2D")
	get_tree().create_timer(.5,false).timeout.connect(set.bind("initial_fall_buffer",false))
	coyote=Timer.new()
	coyote.name="CoyoteTimer"
	coyote.one_shot=true
	coyote.wait_time=.02
	coyote.timeout.connect(fall)
	add_child(coyote)
	fall_timer=Timer.new()
	fall_timer.name="FallTimer"
	fall_timer.one_shot=true
	fall_timer.wait_time=.5
	fall_timer.timeout.connect(end_fall)
	add_child(fall_timer)
	
	floor_checker=Area2D.new()
	floor_checker.visible=false
	floor_checker.set_collision_layer_value(1,false)
	floor_checker.set_collision_mask_value(1,false)
	floor_checker.set_collision_mask_value(19,true)
	var shape=CollisionShape2D.new()
	shape.shape=CircleShape2D.new()
	shape.shape.radius=4*size
	floor_checker.add_child(shape)
	add_child(floor_checker)
	floor_checker.position=Vector2.ZERO
	floor_checker.body_entered.connect(reentered_floor.unbind(1))
	floor_checker.body_exited.connect(left_floor.unbind(1))
		
	if can_jump:
		landing_checker=Area2D.new()
		landing_checker.visible=false
		landing_checker.set_collision_layer_value(1,false)
		landing_checker.set_collision_mask_value(1,false)
		landing_checker.set_collision_mask_value(18,true)
		shape=CollisionShape2D.new()
		shape.shape=CircleShape2D.new()
		shape.shape.radius=4
		landing_checker.add_child(shape)
		add_child(landing_checker)
		landing_checker.position=Vector2.ZERO
		landing_checker.body_exited.connect(stop_jump.unbind(1))
	
func add_status_effect(status:Node):
	status_effects.append(status)
	if status is Harpoon:
		hurtbox.take_hit.connect(status.hit_enemy)
	
func remove_status_effect(status:Node):
	if !status in status_effects:
		return
	if status is Harpoon:
		hurtbox.take_hit.disconnect(status.hit_enemy)
	
func reentered_floor():
	on_floor=true
	coyote.stop()
	
func left_floor():
	on_floor=false
	
func jump():
	if !on_floor:
		fall()
	coyote.stop()
	jumping=true
	set_collision_mask_value(18,false)
	landing_checker.set_deferred("monitoring",true)
	
func land():
	coyote.call_deferred("start")
	jumping=false
	if landing_checker.monitoring and !landing_checker.has_overlapping_bodies():
		stop_jump()
	
func stop_jump():
	set_collision_mask_value(18,true)
	landing_checker.set_deferred("monitoring",false)

func fall():
	if !on_floor:
		falling=true
		if body_sprite:
			body_sprite_y_offset=body_sprite.offset.y
		fall_timer.start()
		started_falling.emit()

func end_fall():
	if !respawn_on_fall:
		queue_free()
		return
	on_floor=true
	falling=false
	fell.emit()
	body_dh=0
	global_position=prev_location
	if player_hurtbox:
		player_hurtbox.call_deferred("take_non_attack_damage")
	if body_sprite:
		body_sprite.offset.y=body_sprite_y_offset
	z_index=0
	if "control" in self:
		self.control.paused=false
	if can_jump:
		land()

func _physics_process(delta):
	if !is_node_ready():
		await ready
	if initial_fall_buffer:
		return
	var shadow_sprite=find_child("Shadow")
	if is_instance_valid(floor_checker) and floor_checker.has_overlapping_bodies():
		if coyote.is_stopped() and !on_floor:
			reentered_floor()
		if !jumping and on_floor:
			prev_location=floor_checker.global_position-velocity.normalized()*4
		if shadow_sprite:
			shadow_sprite.visible=true
	elif is_instance_valid(floor_checker):
		if on_floor:
			left_floor()
		if shadow_sprite:
			shadow_sprite.visible=false
		if !jumping and coyote.is_stopped() and not falling:
			coyote.start()
	
	if on_floor and falling:
		falling=false
		fall_timer.stop()
		z_index=0
		if body_sprite:
			body_sprite.offset.y=body_sprite_y_offset
		if "control" in self:
			self.control.paused=false
		return
	
	if falling:
		#z_index-=round(60*delta)
		if body_sprite:
			body_dh+=delta*10 
			body_sprite.offset.y+=body_dh
		if "control" in self:
			self.control.paused=true
