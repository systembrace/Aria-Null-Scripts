extends Node
class_name StateMachine

@export var initial_state: State
@export var force_target_state=true
@export var searchfield: SearchField
var ray: RayCast2D
@export var hurtbox: Hurtbox
@export var hitstun: Hitstun
@export var combo: Combo
@export var health: Health
@export var dodge=0.0
@export var can_retarget=false
@onready var body: CharacterBody2D = get_parent()
var current_state: State
var states={}
var stunned=false
var dying=false
var dead=false
var out_of_combat=true
var timer
var paused=false

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
		initial_state.enter()
		current_state=initial_state
	if hitstun:
		hitstun.stunned.connect(stun)
		hitstun.recover.connect(recover)
	if health:
		health.dead.connect(death_throes)
	if hurtbox: 
		hurtbox.take_hit.connect(take_damage)

func take_damage(_area=null, _parry=false):
	pass

func death_throes():
	body.set_collision_mask_value(18,false)
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
	if dead:
		return
	if dying:
		hurtbox.disable_hurtbox()
	if body.target!=null and !is_instance_valid(body.target):
		body.target=null
	if current_state and not stunned:
		out_of_combat=(!is_instance_valid(body.target) or body.target is Event) and (!combo or combo.is_done_attacking())
		if searchfield and (not body.target or (can_retarget and timer.is_stopped() and (!combo or combo.is_done_attacking()))):
			if can_retarget:
				timer.start()
			searchfield.monitoring=true
			var notarget=!is_instance_valid(body.target)
			var potentialtarget=searchfield.find_body()
			if is_instance_valid(potentialtarget) and body.target!=potentialtarget:
				if body.target==null:
					searchfield.found()
				body.target=potentialtarget
				searchfield.monitoring=false
				if notarget and force_target_state:
					force_transition("follow")
		elif body.target and randf()<dodge and $Dodge.can_dodge():
			force_transition("dodge")
		#if !paused:
		if !body.jumping:
			current_state.update()
	elif (stunned or dying) and combo:
		combo.enable_attack()

func _physics_process(_delta):
	if dead:
		return
	if (stunned or dying) and body.on_floor:
		body.velocity=body.velocity.move_toward(Vector2.ZERO,16)
		if dying and body.velocity.length()<.1:
			die()
	elif current_state:
		current_state.physics_update()

func transition_state(old_state, new_state_name):
	if body.target!=null and !is_instance_valid(body.target):
		body.target=null
	if old_state!=current_state:
		return
	var new_state=states.get(new_state_name.to_lower())
	if not new_state:
		print("state not found")
		return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state=new_state
	
func force_transition(new_state_name):
	transition_state(current_state, new_state_name)
