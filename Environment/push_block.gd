extends CharacterBody2D
class_name PushBlock

@export var occupying: RailTile
@export var accel=16
@export var up_on=true
@export var right_on=true
@export var left_on=true
@export var down_on=true
var dir=Vector2.ZERO
var mod=1
var turning: RailTile
@onready var hurtbox=$Hurtbox
@onready var tileswapper=$CollisionShape2D

func _ready():
	var main=get_tree().get_root().get_node("Main")
	if main.dark:
		$LockRotation/Light.enabled=true
	hurtbox.take_hit.connect(hit)
	if !up_on:
		$LockPosition/UpOn.hide()
	if !right_on:
		$LockPosition/RightOn.hide()
	if !left_on:
		$LockPosition/LeftOn.hide()
	if !down_on:
		$LockPosition/DownOn.hide()

func bump(hit_dir):
	$SpriteGroup.global_position=global_position+hit_dir*4

func hit(area:Hitbox):
	var hit_dir=area.knockback_vector(self.global_position).normalized()
	if !area.heavy:
		bump(hit_dir)
		return
	if area.destructive:
		mod=2
	$Hit.play()
	var result=occupying.try_move_obj(hit_dir)
	if !result:
		bump(hit_dir)
		return
	$Roll.play()
	if area.targetparent is Player:
		Global.hitstop(.05)

func stop():
	$Hit.play()
	$Roll.stop()
	bump(dir)

func _process(delta):
	if $SpriteGroup.position!=Vector2.ZERO:
		$SpriteGroup.position=$SpriteGroup.position.move_toward(Vector2.ZERO,60*delta)
	if !turning:
		return
	var near_center=to_local(turning.global_position).length()<=4
	if abs(turning.rotate)==1 and near_center:
		rotation_degrees+=45*turning.rotate
		turning.rotate=sign(turning.rotate)*.5
	elif abs(turning.rotate)==0.5 and !near_center:
		rotation_degrees+=45*sign(turning.rotate)
		turning.rotate=0
		turning=null
		if occupying.rotate!=0:
			turning=occupying
