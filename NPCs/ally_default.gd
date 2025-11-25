extends State
class_name AllyDefault

@export var navigator:Navigator
@export var dash: EnemyDodge
@export var look_for_waypoints=true
@export var follow_dist=48
@export var change_speed=0
var main: Main
var speed
var accel
var player:CharacterBody2D
var waypoint: Waypoint
var direction=Vector2.ZERO
@onready var ray=$RayCast2D

func enter():
	main=get_tree().get_root().get_node("Main")
	body.target=null
	accel=body.accel/2
	speed=body.max_speed
	if change_speed:
		speed/=2
	if is_instance_valid(main.player) and !body.tessa:
		player=main.player

func update():
	if look_for_waypoints:
		if main.current_waypoint and (main.current_waypoint.active or !main.current_waypoint.clear_current) and waypoint!=main.current_waypoint:
			waypoint=main.current_waypoint
		if waypoint and (!main.current_waypoint or (not main.current_waypoint.active and main.current_waypoint.clear_current)):
			waypoint=null
		if waypoint and (waypoint.active or !main.current_waypoint.clear_current):
			if body.global_position.distance_to(waypoint.global_position)<8:
				waypoint.actor_reached(body)
				direction=Vector2.ZERO
				waypoint=null
				return
			direction=navigator.next_direction(main.current_waypoint.global_position)
			return
	if not is_instance_valid(player) or (body.tessa and player is Ally and Global.get_flag("with_tessa")):
		if is_instance_valid(main.player) and (!body.tessa or Global.get_flag("with_tessa")):
			player=main.player
		elif body.tessa and !Global.get_flag("with_tessa") and "Cherry" in main.npcs:
			player=main.npcs["Cherry"]
		elif body.tessa and is_instance_valid(main.player_corpse):
			player=main.player_corpse
		direction=Vector2.ZERO
		return
	var dist=body.global_position.distance_to(player.global_position)
	if !player is PlayerCorpse and dist<follow_dist:
		direction=Vector2.ZERO
		return
	elif player is PlayerCorpse and dist<12:
		direction=Vector2.ZERO
		body.kneeling=true
		return
	elif body.kneeling:
		body.kneeling=false
	if dist>change_speed and speed<body.max_speed:
		speed=body.max_speed
	elif dist<change_speed and speed>=body.max_speed:
		speed/=2
	elif dist>change_speed*2 and body.move_and_collide(body.velocity,true):
		body.set_collision_mask_value(10,false)
		body.set_collision_mask_value(20,false)
	if dist<change_speed*1.5 and !body.get_collision_mask_value(10):
		body.set_collision_mask_value(10,true)
		body.set_collision_mask_value(20,true)
	direction=navigator.next_direction(player.global_position)

func temp_target(node):
	var new_waypoint=Waypoint.new()
	main.add_child(new_waypoint)
	new_waypoint.global_position=body.global_position+Vector2.RIGHT.rotated(snapped(navigator.next_direction(node.global_position).angle(),PI/4))
	get_tree().create_timer(10,false).timeout.connect(new_waypoint.queue_free)
	body.target=new_waypoint

func physics_update():
	if dash and body.on_floor and dash.timer.is_stopped():
		ray.target_position=direction.normalized()*8
		ray.force_raycast_update()
		if ray.is_colliding() and is_instance_valid(player) and (player is PlayerCorpse or player.on_floor):
			if waypoint:
				temp_target(waypoint)
			else:
				temp_target(player)
			dash.go_to="Wander"
			transition.emit(self,"Dodge")
			return
	var tempspeed=speed
	#if !waypoint and is_instance_valid(player) and body.global_position.distance_to(player.global_position)>128:
	#	tempspeed*=2
	body.velocity=body.velocity.move_toward(direction*tempspeed,accel)

func exit():
	pass
