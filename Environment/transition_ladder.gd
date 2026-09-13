extends StaticBody2D
class_name TransitionLadder

@export var transition: Transition
@export var dropped=true
@onready var climb_interact: Interactable=$ClimbInteractable

func _ready():
	get_tree().get_root().get_node("Main").ready.connect(init_drop)
	if !dropped and not self is DropLadder:
		add_to_group("objs_to_load")
	climb_interact.interacted.connect(call_transition)
	$TransitionTimer.wait_time=0.5

func init_drop():
	if !dropped and not self is DropLadder:
		not_dropped()

func not_dropped():
	hide()
	for child in get_children():
		child.queue_free()

func call_transition(interacted):
	if interacted is Player and interacted.original_player:
		transition.on_body_entered(interacted)
		$TransitionTimer.timeout.connect(transition.change_scene.bind(interacted))
		$TransitionTimer.start()
