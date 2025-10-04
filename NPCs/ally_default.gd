extends State
class_name AllyDefault

@export var navigator:Navigator
@export var dash: EnemyDodge
var follow_dist=48
var main
var speed
var accel
var player:Player
var waypoint: Waypoint
var direction=Vector2.ZERO
@onready var ray=$RayCast2D

func enter():
	main=get_tree().get_root().get_node("Main")
	body.target=null
	accel=body.accel/2
	speed=body.max_speed
	if is_instance_valid(main.player):
		player=main.player

func update():
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
	if not is_instance_valid(player):
		if is_instance_valid(main.player):
			player=main.player
		direction=Vector2.ZERO
		return
	if body.global_position.distance_to(player.global_position)<follow_dist:
		direction=Vector2.ZERO
		return
	direction=navigator.next_direction(player.global_position)

func temp_target(node):
	var new_waypoint=Waypoint.new()
	main.add_child(new_waypoint)
	new_waypoint.global_position=body.global_position+Vector2.RIGHT.rotated(snapped(navigator.next_direction(node.global_position).angle(),PI/4))
	get_tree().create_timer(10,false).timeout.connect(new_waypoint.queue_free)
	body.target=new_waypoint

func physics_update():
	ray.target_position=direction.normalized()*8
	ray.force_raycast_update()
	if ray.is_colliding():
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
