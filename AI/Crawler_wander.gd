extends State
class_name CrawlerWander

@export var min_wait=1.0
@export var max_wait=3.0
var speed=0
var accel=0
var direction=Vector2.ZERO
@onready var timer=$Timer

func _ready():
	timer.timeout.connect(cycle)
	timer.wait_time=randf_range(min_wait,max_wait)

func enter():
	speed=body.max_speed
	accel=body.accel
	timer.start()

func cycle():
	timer.wait_time=randf_range(min_wait,max_wait)
	if body.move_dir!=0 and not body.on_corner:
		body.move_dir=0
		timer.wait_time=min(timer.wait_time,1.5)
	elif body.move_dir==0:
		body.move_dir=randi_range(0,1)*2-1
	timer.start()
	body.update_rotation()

func update():
	if !body.on_wall:
		transition.emit(self,"Wander")
		return
	if is_instance_valid(body.target):
		transition.emit(self,"Attack")
		return
	if body.move_dir!=0:
		direction=body.wall_dir.rotated(-PI/2*body.move_dir)
	else:
		direction=Vector2.ZERO

func physics_update():
	body.velocity=body.velocity.move_toward(direction*speed,accel)

func exit():
	timer.stop()
