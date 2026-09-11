extends TransitionLadder
class_name DropLadder

@export var drop_height=128
@export var counterpart_room="checkpoint_2"
@export var counterpart_name="TransitionLadder"
var dropping=false
var dy=0
@onready var drop_sprite=$Mask/Drop
@onready var drop_interact: Interactable=$DropInteractable
@onready var main:Main=get_tree().get_root().get_node("Main")

func _ready():
	super._ready()
	drop_height+=drop_sprite.offset.y

func drop():
	dropping=true
	$Slide.play()

func set_dropped():
	dropping=false
	dropped=true
	drop_interact.deactivate()
	drop_sprite.offset.y=drop_height
	climb_interact.activate()
	var config=ConfigFile.new()
	config.load(main.config_name)
	if !config.get_value(counterpart_room,counterpart_name):
		config.set_value(counterpart_room,counterpart_name,true)
		config.save(main.config_name)

func _physics_process(delta):
	if !dropping:
		return
	dy+=5*delta
	drop_sprite.offset.y+=dy
	if drop_sprite.offset.y>=drop_height:
		set_dropped()
		$Thud.play()
		$Slide.call_deferred("stop")
