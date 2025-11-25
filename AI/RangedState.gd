extends LockonState
class_name RangedState

@export var gun: Gun
@export var delay_time=0.5
@export var lock_time=0.25
@export var recharge_time=3.0
@export var has_melee=true
@export var hitstun: Hitstun
@export var spread_chance=0.0
@export var spread_angle=60
@export var spread_time=1.0
@export var shoot_close=false
@export var never_hide=false
var guns: Dictionary[String, Gun] = {}
var spread=false
var angle_step=0
var tempbuffer=0
var lock_pos=Vector2.ZERO
var delay:Timer=null
var lock:Timer=null
var ready_sfx: SoundPlayer

func _ready():
	for child in get_children():
		if child is Gun:
			guns[child.name]=child
			if child.name=="Gun":
				gun=child
	spread_angle=spread_angle/360.0*2*PI
	if find_child("DelayTimer"):
		delay=$DelayTimer
		delay.timeout.connect(shoot)
	if delay_time>0.0:
		delay.wait_time=delay_time
		ready_sfx=$Ready
		
	if find_child("LockTimer"):
		lock=$LockTimer
		lock.wait_time=0.0001
		lock.timeout.connect(lock_on)
	if lock_time>0.0:
		lock.wait_time=lock_time
	if hitstun:
		hitstun.stunned.connect(reload)
		hitstun.stunned.connect(gun.cancel_shot)
		hitstun=null

func enter():
	gun.equip(body)
	super.enter()
	reload()
	if randf()<spread_chance:
		spread=true
		var dir=randi_range(0,1)*2-1
		gun.angle_offset=dir*spread_angle/2
		angle_step=-dir*spread_angle/gun.numshots
		gun.buffer.wait_time=gun.buffertime/gun.numshots*spread_time
		if is_instance_valid(target):
			lock_pos=target.global_position

func equip_gun(gun_name):
	if !gun_name in guns:
		return
	gun=guns[gun_name]
	gun.equip(body)
	reset_target()

func set_delay(time):
	delay_time=time
	if delay_time>0:
		delay.wait_time=delay_time

func lock_on():
	if is_instance_valid(target):
		lock_pos=target.global_position

func try_shoot():
	if !shoot_close and targetdist<=64 and delay_time>0 and !delay.is_stopped():
		delay.stop()
		gun.cancel_shot()
		if !never_hide:
			gun.always_show=false
		gun.readying=false
	
	if gun.can_use() and targetdist>64 and can_see_target() and body.ammo>=60.0/gun.numshots and (delay_time==0 or delay.is_stopped()):
		if delay_time>0:
			if body.ammo==60.0:
				delay.wait_time=delay_time
				if lock_time>0:
					lock.wait_time=lock_time
				gun.readying=true
				if ready_sfx:
					ready_sfx.play()
			else:
				delay.wait_time=gun.buffertime
				lock.wait_time=0.001
				if lock and delay.wait_time>delay_time-lock_time:
					lock.wait_time=delay.wait_time-delay_time+lock_time
			if lock and lock.wait_time>0.001:
				lock.start()
			elif lock.wait_time<=0.001:
				lock_on()
			gun.always_show=true
			delay.start()
			return
		shoot()

func shoot():
	if !is_instance_valid(target):
		return
	gun.readying=false
	if !never_hide:
		gun.always_show=false
	gun.shoot(lock_pos)
	if spread:
		gun.angle_offset+=angle_step
	body.ammo-=60.0/gun.numshots
	if body.ammo<=60.0/gun.numshots:
		reload()

func reload():
	body.ammo=-recharge_time*5

func update():
	if target!=body.target:
		reset_target()
	if !is_instance_valid(target) or target.control.health.hp<=0:
		transition.emit(self,"Wander")
		return
	update_targetdist()
	if targetdist>combat_dist:
		transition.emit(self,"Follow")
	if has_melee and (targetdist<min_dist or body.ammo<60.0/gun.numshots):
		transition.emit(self,"Attack")
		return
	
	try_shoot()
	
	super.update()
	
	if delay_time>0 and !delay.is_stopped():
		direction=Vector2.ZERO

func physics_update():
	body.velocity=body.velocity.move_toward(direction*speed,accel)

func exit():
	if !never_hide:
		gun.hide_sprite()
	gun.angle_offset=0
	gun.buffer.wait_time=gun.buffertime
	lock_pos=Vector2.ZERO
	spread=false
