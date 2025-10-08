extends Gun
class_name Grapple

var deployed=false
var sprite_offs=Vector2.ZERO
var harpoon: Harpoon
var retracting=false
var pulling=false
@onready var tether=$Tether
@onready var pull_timer=$PullTimer

func _ready():
	main=get_tree().get_root().get_node("Main")
	stand.wait_time=standtime
	stand.timeout.connect(allow_move)
	buffer.wait_time=buffertime
	buffer.timeout.connect(set.bind("firing",false))
	buffer.timeout.connect(hide_sprite)
	pull_timer.wait_time=5
	length=sprite.sprite_frames.get_frame_texture("empty",0).get_width()
	sprite.offset=offset

func updatesprite():
	if !retracting:
		dir=target_dir()
	else:
		dir=to_local(harpoon.global_position).normalized()
			
	var state="full"
	if deployed:
		state="empty"
	
	sprite.flip_v=false
	sprite.z_index=1
	if cloak:
		$Cloak.visible=false
	sprite.position.x=0
	sprite.rotation=dir.angle()
	if abs(dir.angle_to(Vector2.UP))<PI/4:
		sprite.animation=state+"_up"
		sprite_offs=Vector2(-4,0)
		sprite.z_index=0
	elif abs(dir.angle_to(Vector2.DOWN))<PI/4:
		sprite.animation=state+"_down"
		sprite_offs=Vector2(2,0)
		if cloak and dir.x>0:
			$Cloak.visible=true
	else:
		sprite.animation=state
		sprite_offs=Vector2(0,-1)
		if dir.x<0:
			sprite.flip_v=true
			#flash.position.x=length
			#flash.position.y=1
		else:
			sprite.position.x=3
	sprite.visible=true
	shooting=true

func use():
	if !deployed:
		shoot()
	elif harpoon.stuck and harpoon.stuck_in_enemy:
		if harpoon.enemy.heavy:
			pull()
		else:
			retract()

#func start_shoot():
	#if !is_instance_valid(target) or firing:
	#	return
	#updatesprite()
	#delay.start()

func shoot(_override=Vector2.ZERO):
	firing=true
	deployed=true
	cant_move=true
	updatesprite()
	tether.points[0]=sprite.position+dir*(length-12)+sprite_offs+Vector2.DOWN
	$Reel.play(-1)
	$Sprite/Gunshot.play()
	harpoon=load("res://Scenes/Secondaries/harpoon.tscn").instantiate()
	main.call_deferred("add_child",harpoon)
	var harpoon_dir=target_dir()
	harpoon.global_position=sprite.global_position+harpoon_dir*26+sprite_offs-Vector2.UP*19
	harpoon.dir=harpoon_dir
	var smoke=flash.duplicate()
	main.add_child(smoke)
	smoke.global_position=flash.global_position
	smoke.process_material=flash.process_material.duplicate()
	smoke.process_material.direction+=Vector3(dir.x,dir.y,2)*.5
	smoke.emitting=true
	stand.start()
	buffer.start()

func retract():
	firing=true
	retracting=true
	updatesprite()
	harpoon.retract()
	buffer.start()
	get_tree().create_timer(.1,false).timeout.connect(hide_sprite)
	$Reel.play(-1)

func pull():
	firing=true
	pulling=true
	updatesprite()
	buffer.start()
	targetparent.jump()
	pull_timer.start()
	$Reel.play(-1)

func hide_sprite():
	shooting=false
	sprite.visible=false
	if cloak:
		$Cloak.visible=false
	if is_instance_valid(targetparent):
		tether.points[0]=tether.to_local(targetparent.global_position)+Vector2.UP*17

func _process(delta):
	super._process(delta)
	queue_redraw()
	if (!is_instance_valid(target) or !target) and sprite.visible:
		hide_sprite()
	if not deployed and firing:
		updatesprite()
	if !is_instance_valid(harpoon):
		tether.points[1]=Vector2.ZERO
		tether.points[0]=Vector2.ZERO
		$Reel.stop()
		return
	if harpoon.collider_moved:
		tether.z_index=0
	elif harpoon.stuck_in_enemy:
		tether.z_index=-1
	tether.points[1]=to_local(harpoon.global_position)-harpoon.dir*16+Vector2.UP*19
	if harpoon.stuck and not harpoon.stuck_in_enemy:
		deployed=false
		retracting=false
		harpoon=null
		return
	retracting=harpoon.retracting
	var travel_vec=harpoon.to_local(global_position-Vector2.UP*19)
	harpoon.tether_length=travel_vec.length()
	harpoon.visible=true
	if retracting or pulling:
		harpoon.dir=travel_vec.normalized()
		if (retracting and travel_vec.length()<8) or (pulling and (travel_vec.length()<16 or pull_timer.is_stopped())):
			if targetparent.control.combo.is_damaging() and is_instance_valid(harpoon.enemy):
				harpoon.visible=false
				return
			if pulling:
				sprite.hide()
				targetparent.land()
			elif retracting and is_instance_valid(harpoon.enemy):
				#harpoon.enemy.velocity=harpoon.dir*harpoon.speed
				harpoon.enemy.land()
				harpoon.enemy.remove_status_effect(harpoon)
			deployed=false
			retracting=false
			pulling=false
			harpoon.queue_free()
			harpoon=null
			buffer.start()
			$Reload.play()
			$Reel.stop()
			return
		elif retracting and is_instance_valid(harpoon.enemy):
			harpoon.hitbox.global_position=harpoon.enemy.global_position+Vector2.UP*16
			harpoon.enemy.velocity=harpoon.velocity
			if travel_vec.length()<=56:
				if !harpoon.hitbox.get_collision_mask_value(2):
					harpoon.hitbox.set_collision_mask_value(2,true)
				harpoon.enemy.velocity*=travel_vec.length()/56.0
		elif pulling and is_instance_valid(harpoon.enemy):
			targetparent.velocity=-travel_vec.normalized()*harpoon.speed/2
			if travel_vec.length()<=56:
				targetparent.velocity*=travel_vec.length()/56.0
	else:
		if travel_vec.length()>320:
			harpoon.make_tether()
			deployed=false
			retracting=false
			pulling=false
			harpoon=null
		elif harpoon.stuck and $Reel.is_playing():
			$Reel.stop()
