extends AnimationController
class_name ClingerAnimationController

func _process(_delta):
	var curr_anim_name=idlename
	var curr_frame=sprite.get_frame()
	var curr_prog=sprite.get_frame_progress()
	var prevanim=anim
	var vertical_sprites_enabled=has_vertical_sprites
	
	if body.velocity.length()>=body.accel/4:
		anim=runname
		curr_anim_name=runname
	else:
		anim=idlename
	
	if !body.on_wall:
		anim=walkname
		curr_anim_name=walkname
	
	if body.velocity.length()>vel_threshold:
		direction=body.velocity
		
	if anim==runname and abs(angle_difference(body.wall_dir.rotated(PI/2).angle(),direction.angle()))>PI/4:
		sprite.speed_scale=-1
	elif sprite.speed_scale!=1:
		sprite.speed_scale=1
		
	if body.on_wall and vertical_sprites_enabled and (abs(body.wall_dir.y)>abs(body.wall_dir.x)):# or body.on_corner):
		sprite.flip_h=false
		if body.wall_dir.y>0:
			curr_anim_name+="_up"
		elif body.wall_dir.y<0:
			curr_anim_name+="_down"
	else:
		if body.wall_dir.x>0:
			sprite.flip_h=true
			sprite.speed_scale*=-1
		elif body.wall_dir.x<0:
			sprite.flip_h=false
	
	if curr_anim_name!=sprite.animation:
		sprite.animation=curr_anim_name
		
		if prevanim==anim:
			sprite.set_frame_and_progress(curr_frame,curr_prog)
		if anim==idlename and randf()>randomidle/60:
			sprite.stop()
		else:
			sprite.play(curr_anim_name)
