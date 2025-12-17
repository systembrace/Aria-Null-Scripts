extends CharacterBody2D
class_name Pickup

@export var enemy: Node2D
@export var item="roly_poly"
signal picked_up
var main
var h=1
var dh=0
var gravity=.3
var bounce=.5
var accel=24
var settled=false
@onready var sprite=$Interactable/AnimatedSprite2D
@onready var interact_area=$Interactable

func _ready():
	if !is_instance_valid(enemy):
		return
	main=get_tree().get_root().get_node("Main")
	interact_area.interacted.connect(interacted)
	hide()
	if enemy is Spawner:
		enemy.spawned.connect(set_death_connection)
		return
	set_death_connection()

func set_death_connection(node=enemy):
	enemy=node
	enemy.death_throes.connect(spawn)

func spawn():
	global_position=enemy.global_position
	show()
	dh=randf_range(4,5)
	bounce=(dh-4)*.05+.6
	velocity=Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()*randf_range(56,96)

func interacted(_node):
	picked_up.emit()
	if item in Global.revives_list:
		Global.set_flag(item,true)
		if main.inventory.revival=="none":
			main.inventory.revival=item
	main.inventory.hud.item_popup.display(item)
	queue_free()

func _process(delta):
	if !visible or settled:
		return
	if abs(dh)>1 or h>2:
		dh-=gravity*60*delta
		if h+dh<0:
			dh*=-1*bounce
			velocity=velocity.rotated(randf_range(0,PI*2))
		h+=dh*60*delta
	elif h!=0:
		h=move_toward(h,0,gravity*60*delta)
		dh=0
	if velocity!=Vector2.ZERO and dh==0 and h<=0:
		velocity=velocity.move_toward(Vector2.ZERO,accel*60*delta)
	if h==0 and velocity==Vector2.ZERO:
		sprite.position.y=0
		settled=true
		sprite.animation="settled"
		interact_area.activate()
		global_position=global_position.round()+Vector2(.5,.5)

func _physics_process(delta):
	if velocity!=Vector2.ZERO:
		var coll = move_and_collide(velocity*delta)
		if coll:
			velocity=velocity.bounce(coll.get_normal())/2
		sprite.position.y=-h
