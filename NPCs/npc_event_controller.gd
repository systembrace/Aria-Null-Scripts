extends Node
class_name NPCEventController

@export var npc_name="generic"
@export var save = false
@export var default: Event
@export var first_interact: Event
@export var interact_map: Dictionary[int,Event] = {}
@export var reactions: Dictionary[String,Event] = {}
@export var has_holo_reaction=false
var interact_count=0
var reactions_given=[]

func _ready():
	if save:
		add_to_group("objs_to_load")

func interact():
	if has_holo_reaction and !get_parent().main.player.original_player:
		find_child(get_parent().main.player.holo_type).activate()
		return
	interact_count+=1
	if first_interact and interact_count==1:
		first_interact.activate()
		return
	#Then any other available reactions
	if interact_count in interact_map.keys():
		interact_map[interact_count].activate()
		return
	default.activate()
