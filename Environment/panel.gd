extends Interactable
class_name InteractPanel

@export var node: Node
@export var function: String
@export var param= false
@export var one_time=true
var disabled=false
signal pressed

func _ready():
	super._ready()
	if get_parent() is Main and get_parent().dark:
		$Popup/PointLight2D.visible=true
	area_entered.connect(turn_on)
	area_exited.connect(turn_off)

func interact(_node = null):
	if !node:
		return
	if param:
		node.call(function, param)
	else:
		node.call(function)
	pressed.emit()
	if one_time:
		disable()
	
func turn_on(_area=null):
	$Popup.visible=true
	$CollisionShape2D.set_deferred("disabled",false)
	disabled=false
	
func turn_off(_area=null):
	$Popup.visible=false
	
func disable():
	$CollisionShape2D.set_deferred("disabled",true)
	turn_off()
	disabled=true
