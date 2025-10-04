extends Node2D
class_name AnimationController

@onready var sprite=$AnimatedSprite2D
@onready var flash_anim=$AnimatedSprite2D/Flash
@onready var flicker:Timer
@onready var body:CharacterBody2D=get_parent()
@export var combo: Combo
@export var hitstun: Hitstun
@export var health: Health
@export var dash: Node
@export var hurtbox: Hurtbox
@export var control: PlayerControl
@export var gun: Secondary
@export var gun_anims=false
@export var hastarget=false
@export var haschargedattack=false
@export var idlename="idle"
@export var has_walk=false
@export var walkname="walk"
@export var runspeed=0
@export var runname="run"
@export var attackname="attack"
@export var readyattackname="ready"
@export var recovername="recover"
@export var stunname="stun"
@export var dashname="dash"
@export var has_fall=false
@export var fallname="fall"
@export var healname="heal"
@export var randomidle:float=-1
@export var has_vertical_sprites=false
@export var out_of_combat_anims=false
@export var flicker_iframes=false
@export var footsteps=-1
var vel_threshold=.02
var direction=Vector2.DOWN
var anim="idle"
signal step

func _ready():
	if health and flash_anim:
		health.hplost.connect(hitflash)
	if flicker_iframes and hurtbox:
		hurtbox.hurtboxenabled.connect(disableflicker)
	if has_fall:
		body.fell.connect(update_fall)
	flicker=$Flicker
	flicker.timeout.connect(hitflash)
	flicker.wait_time=.15

func update_fall():
	sprite.animation=stunname

func disableflicker():
	flicker.stop()

func hitflash(dead=false):
	flash_anim.stop()
	flash_anim.play("hitflash")
	if flicker_iframes or dead:
		flicker.start()

func _process(_delta):
	var curr_anim_name=idlename
	var curr_frame=sprite.get_frame()
	var curr_prog=sprite.get_frame_progress()
	var prevanim=anim
	var vertical_sprites_enabled=has_vertical_sprites
	
	if body.velocity.length()>=body.accel/4:
		anim=runname
		if has_walk and body.velocity.length()<body.min_speed+body.accel:
				anim=walkname
				curr_anim_name=walkname
		else:
			curr_anim_name=runname
	else:
		anim=idlename
	
	if combo:
		if combo.is_damaging():
			anim=attackname
			curr_anim_name=attackname
		
		if combo.is_readying():
			anim=readyattackname
			curr_anim_name=readyattackname
			
		if combo.current_attack.has_recovery and ((body is Player and combo.is_recovering()) or (combo.is_done_attacking() and !combo.can_move())):
			anim=recovername
			curr_anim_name=recovername
	
	if body.falling and has_fall:
		anim=fallname
		curr_anim_name=fallname
	
	if dash and dash.dashing and (not combo or not curr_anim_name==attackname):
		anim=dashname
		curr_anim_name=dashname
	
	if control and control.healing:
		anim=healname
		curr_anim_name=healname
		vertical_sprites_enabled=false
	
	if control and control.inventory and (control.inventory.secondary is Gun or control.inventory.secondary is Grapple):
		gun=control.inventory.secondary
	
	if hitstun and hitstun.stunning:
		anim=stunname
		curr_anim_name=stunname
		vertical_sprites_enabled=false
	
	if (anim==attackname or anim==readyattackname or anim==recovername) and combo and combo.current_attack.unique_anim:
		curr_anim_name+="_"+str(combo.current_attack.combo_index)
	
	if body.velocity.length()>vel_threshold:
		if (hastarget or (haschargedattack and Input.is_action_pressed("attack"))) and (anim==runname or anim==readyattackname or anim==walkname) and is_instance_valid(body.target):
			direction=body.to_local(body.target.global_position)*2
		else:
			direction=body.velocity
	if combo and ((combo.is_attacking() and anim==attackname) or (not haschargedattack and combo.is_readying() and anim==readyattackname)):
		direction=body.to_local(combo.current_attack.hitbox.global_position)
	if gun and gun.firing:
		direction=gun.dir
	if vertical_sprites_enabled and abs(direction.y)>abs(direction.x):
		sprite.flip_h=false
		if direction.y<0:
			curr_anim_name+="_up"
		elif direction.y>0:
			curr_anim_name+="_down"
	else:
		if direction.x>0:
			sprite.flip_h=true
			if gun and !vertical_sprites_enabled and ("_up" in gun.sprite.animation or "_down" in gun.sprite.animation):
				gun.sprite.flip_v=false
		elif direction.x<0:
			sprite.flip_h=false
			if gun and !vertical_sprites_enabled and ("_up" in gun.sprite.animation or "_down" in gun.sprite.animation):
				gun.sprite.flip_v=true
	
	if out_of_combat_anims and body.control.out_of_combat and combo.can_move() and curr_anim_name!=stunname:
		curr_anim_name="ooc_"+curr_anim_name
	elif gun_anims and (gun.shooting or gun.readying) and (curr_anim_name==runname or curr_anim_name==walkname or curr_anim_name==idlename):
		curr_anim_name="gun_"+curr_anim_name
	
	if runspeed>0 and anim==runname:
		sprite.speed_scale=min(1,body.velocity.length()/body.max_speed*runspeed)
		if hastarget and body.velocity.angle_to(direction)>PI/4:
			sprite.speed_scale*=-1
	elif sprite.speed_scale!=1:
		sprite.speed_scale=1
	
	if curr_anim_name!=sprite.animation:
		sprite.animation=curr_anim_name
		
		if prevanim==anim:
			sprite.set_frame_and_progress(curr_frame,curr_prog)
		if anim==idlename and randf()>randomidle/60:
			sprite.stop()
		else:
			sprite.play(curr_anim_name)
			
	if footsteps>-1:
		if anim==runname or anim==walkname:
			var cycle=sprite.sprite_frames.get_frame_count(sprite.animation)/2
			if (sprite.frame==1 or sprite.frame==cycle+1) and sprite.frame!=footsteps:
				footsteps=sprite.frame
				step.emit()
		elif anim!=prevanim:
			footsteps=99
			if (anim!=idlename or (anim==idlename and prevanim==walkname)) and anim!=readyattackname and anim!=recovername and sprite.frame==0:
				step.emit()
