extends Node
class_name Dash

@export var dashspeed=400
@export var dashbuffer=.4
@export var iframesbuffer=.32
@export var node: PlayerControl
@export var hurtbox: Hurtbox
@onready var buffer=$BufferTimer
@onready var iframes=$IframesTimer
var dashing=false
signal dash_started
var inputdir=Vector2.RIGHT
var veldir=Vector2.RIGHT
var dir

func _ready():
	buffer.wait_time=dashbuffer
	buffer.timeout.connect(end_dash)
	iframes.wait_time=iframesbuffer
	iframes.timeout.connect(hurtbox.enable_hurtbox)
	iframes.timeout.connect(get_parent().set_collision_layer_value.bind(9,true))

func _process(_delta):
	if Global.load_config("game","dash_to_cursor"):
		dir=get_parent().to_local(get_parent().get_global_mouse_position()).normalized()
	else:
		dir=get_parent().dir

func end_dash():
	dashing=false
	get_parent().land()

func start_dash():
	if not dashing and dir:
		dashing=true
		hurtbox.disable_hurtbox()
		get_parent().jump()
		get_parent().set_collision_layer_value(9,false)
		iframes.start()
		#node.body.velocity=dir*(dashspeed+float(node.speed-node.min_speed)/float(node.max_speed-node.min_speed)*80)
		node.body.velocity=dir*dashspeed
		dash_started.emit()
		buffer.start()
