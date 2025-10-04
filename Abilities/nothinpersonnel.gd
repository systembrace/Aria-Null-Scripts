extends Attack
class_name NothinPersonnel

@export var overshoot=1
@export var trail: Line2D
var numshots=3
@onready var ray=$RayCast2D
@onready var check_area=$CheckArea
@onready var sprite=$Destination

func can_use():
	return can_attack

func use():
	get_parent().attack_index(combo_index)

func teleport(teldir,ovr=1):
	ray.global_rotation=0
	ray.global_position=targetparent.global_position
	ray.target_position=teldir*ovr
	ray.force_raycast_update()
	check_area.global_position=ray.global_position+ray.target_position
	check_area.global_rotation=0
	if ray.is_colliding():
		targetparent.global_position=ray.get_collision_point()-teldir.normalized()*16
	elif check_area.move_and_slide():
		targetparent.global_position=check_area.global_position-teldir.normalized()*20
	else:
		targetparent.global_position+=teldir*ovr

func attack():
	sprite.visible=false
	sprite.stop()
	if not is_instance_valid(target):
		target=null
		enable_attack()
		return
	attacking=true
	done_attacking=false
	can_attack=false
	if finished_time!=0:
		can_move=false
	readying=false
	var start_pos=targetparent.global_position
	var teldir=targetparent.to_local(target.global_position)
	if overshoot==0:
		teleport(teldir)
	if overshoot>0:
		targetparent.global_position+=teldir
		teleport(teldir,overshoot)
	hitbox.shape.size.x=targetparent.to_local(start_pos).length()+8+12
	hitbox.position.x=-targetparent.to_local(start_pos).length()/2+6
	enable_hitbox()
	attack_timer.start()
	trail.points[1]=targetparent.to_local(start_pos)
	var ring=$DustRing.duplicate()
	get_tree().get_root().get_node("Main").add_child(ring)
	ring.global_position=start_pos
	ring.emitting=true
	ring.modulate=Color.WHITE
	ring.finished.connect(ring.queue_free)

func disable_hitbox():
	super.disable_hitbox()
	sprite.visible=false

func _process(delta):
	if !is_instance_valid(targetparent.target):
		enable_attack()
		trail.points[1]=Vector2.ZERO
		return
	super._process(delta)
	if trail.points[1]!=Vector2.ZERO:
		trail.points[1]=trail.points[1].move_toward(Vector2.ZERO,16)
	if readying:
		sprite.visible=true
		sprite.global_position=targetparent.target.global_position
		sprite.global_rotation=0
		if !sprite.is_playing():
			sprite.play()
	queue_redraw()

func _draw():
	if readying:
		var thickness=1.5
		if sprite.frame>14:
			thickness=8
		draw_line(Vector2.ZERO,sprite.position,"e512507F",thickness)
