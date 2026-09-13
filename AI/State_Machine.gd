extends Node
class_name StateMachine

@export var initial_state: State
@export var force_target_state=true
@export var searchfield: SearchField
@export var hurtbox: Hurtbox
@export var hitstun: Hitstun
@export var combo: Combo
@export var health: Health
@export var dash: EnemyDodge
@export var navigator_for_dash: Navigator
@export var dodge=0.0
@export var can_retarget=false
@export var friction_dying=true
var ray: RayCast2D
var jump_finder: RayCast2D
var current_state: State
var states={}
var stunned=false
var dying=false
var dead=false
var out_of_combat=true
var timer
var paused=false
var dont_notice=false
var process_physics=true
@onready var main=get_tree().get_root().get_node("Main")
@onready var body: CharacterBody2D = get_parent()

func _ready():
	if can_retarget:
		timer=Timer.new()
		timer.one_shot=true
		timer.wait_time=.5
		add_child(timer)
	for child in get_children():
		if child is State:
			states[child.name.to_lower()]=child
			child.transition.connect(transition_state)
			child.body=body
	if initial_state:
		initial_state.call_deferred("enter")
		current_state=initial_state
	if hitstun:
		hitstun.stunned.connect(stun)
		hitstun.recover.connect(recover)
	if health:
		health.dead.connect(death_throes)
	if hurtbox: 
		hurtbox.take_hit.connect(take_damage)
	if dash:
		ray=RayCast2D.new()
		ray.set_collision_mask_value(1,false)
		ray.set_collision_mask_value(18,true)
		add_child(ray)
		jump_finder=RayCast2D.new()
		jump_finder.set_collision_mask_value(1,false)
		jump_finder.set_collision_mask_value(25,true)
		jump_finder.collide_with_areas=true
		jump_finder.collide_with_bodies=false
		add_child(jump_finder)

func take_damage(_area=null, _parry=false):
	pass

func temp_target(node):
	var new_waypoint=Waypoint.new()
	main.add_child(new_waypoint)
	new_waypoint.global_position=node.global_position#body.global_position+Vector2.RIGHT.rotated(navigator_for_dash.next_direction(node.global_position).angle())
	var targettimer=get_tree().create_timer(10,false)
	targettimer.timeout.connect(new_waypoint.queue_free)
	targettimer.timeout.connect(body.set.bind("target",body.target))
	body.target=new_waypoint

func death_throes():
	body.death_throes.emit()
	body.set_collision_mask_value(18,false)
	body.set_collision_mask_value(24,false)
	body.nav_agent.avoidance_enabled=false
	dying=true
	if hitstun:
		hitstun.stun()
		if find_child("Die"):
			var main=get_tree().get_root().get_node("Main")
			var die_sfx=$Die.duplicate()
			main.add_child(die_sfx)
			die_sfx.finished.connect(die_sfx.queue_free)
			die_sfx.global_position=body.global_position
			die_sfx.play()
	else:
		die()

func die():
	if !body.on_floor:
		return
	dead=true
	body.queue_free()

func stun():
	stunned=true
	if combo:
		combo.enable_attack()
	
func recover():
	if combo:
		combo.enable_attack()
	stunned=false

func _process(_delta):
	out_of_combat=false
	if dead or paused:
		return
	if dying:
		if !body.on_floor:
			body.set_collision_mask_value(19,true)
		hurtbox.disable_hurtbox()
	if body.target!=null and !is_instance_valid(body.target):
		body.target=null
	if current_state and not stunned:
		out_of_combat=(!is_instance_valid(body.target) or body.target is Event or body.target is Waypoint) and (!combo or combo.is_done_attacking())
		if searchfield and (not body.target or (can_retarget and timer.is_stopped() and (!combo or combo.is_done_attacking()))):
			if can_retarget:
				timer.start()
			searchfield.monitoring=true
			var notarget=!is_instance_valid(body.target)
			var potentialtarget=searchfield.find_body()
			if is_instance_valid(potentialtarget) and body.target!=potentialtarget:
				if body.target==null and !dont_notice:
					searchfield.found()
				dont_notice=false
				body.target=potentialtarget
				searchfield.monitoring=false
				if notarget and force_target_state:
					force_transition("follow")
		elif body.target and randf()<dodge and $Dodge.can_dodge():
			force_transition("dodge")
		if !body.jumping or body.on_floor or current_state.name.to_lower()=="dodge":
			if body.jump_point and current_state!=dash:
				current_state.direction=navigator_for_dash.next_direction(body.jump_point.global_position)
				if body.to_local(body.jump_point.global_position).length()<16:
					body.jump_point=null
				return
			current_state.update()
	elif (stunned or dying) and combo:
		combo.enable_attack()

func _physics_process(delta):
	if dead:
		return
	if (stunned or dying) and body.on_floor:
		if (!dying and stunned) or friction_dying:
			body.velocity=body.velocity.move_toward(Vector2.ZERO,16)
		if dying and (body.velocity.length()<.1 or (!friction_dying and body.move_and_collide(body.velocity*delta,true))):
			die()
		return
	if current_state and process_physics:
		if dash and body.on_floor and dash.timer.is_stopped() and body.get_collision_mask_value(18) and current_state!=dash:
			ray.position=Vector2.ZERO
			ray.target_position=current_state.direction.normalized()*8
			ray.force_raycast_update()
			var do_dash=false
			if ray.is_colliding() and (!body is NPC or (current_state is AllyDefault and (current_state.waypoint or is_instance_valid(current_state.player)))):
				#if body is NPC and current_state.waypoint:
				#	temp_target(current_state.waypoint)
				#	do_dash=true
				#else:
				jump_finder.position=current_state.direction.normalized()*16
				jump_finder.target_position=current_state.direction.normalized()*dash.dodge_dist
				jump_finder.force_raycast_update()
				var jump_point=jump_finder.get_collider()
				if is_instance_valid(jump_point):
					body.jump_point=jump_point
					temp_target(jump_point)
					do_dash=true
					#elif body is NPC and (current_state.player is PlayerCorpse or current_state.player.on_floor):
					#	temp_target(current_state.player)
					#	do_dash=true
					#else:
					#	var new_node=Node2D.new()
					#	new_node.global_position=body.global_position+current_state.direction*16
					#	temp_target(new_node)
				if do_dash:
					dash.go_to=current_state.name
					force_transition("Dodge")
					return
		current_state.physics_update()
	body.nav_agent.set_velocity(body.velocity)

func transition_state(old_state, new_state_name):
	if body.target!=null and !is_instance_valid(body.target):
		body.target=null
	if old_state!=current_state:
		return
	var new_state=states.get(new_state_name.to_lower())
	if not new_state:
		print(body.name+": state "+new_state_name+" not found")
		return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state=new_state
	
func force_transition(new_state_name):
	transition_state(current_state, new_state_name)
