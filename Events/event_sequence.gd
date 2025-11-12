extends Node
class_name EventSequence

var events=[]
var active="None"
var last_waypoint=Waypoint
var npc_endings=[]

func _ready():
	var prev=null
	for child in get_children():
		if child is Event:
			events.append(child)
			child.prev=prev
			if prev:
				prev.next=child
			prev=child
			if !child.only_branch_here_backwards:
				child.activated.connect(currently_active)
			child.sequence_finished.connect(currently_active.bind("None"))
			if child is Waypoint:
				last_waypoint=child
			if child is EndNPCEvent:
				npc_endings.append(child)
	events[0].activate()

func currently_active(eventname):
	active=eventname
	
func set_active(loaded_name):
	if !is_node_ready():
		await ready
	print("trying to load "+loaded_name)
	if loaded_name=="None":
		print("skipping all events")
		events[len(events)-1].skip(true)
		active="None"
		return
	var event: Event = find_child(loaded_name)
	if !event:
		print("could not find event to load")
		return
	if event is DialogueEvent:
		if event.coroutine:
			event=event.next
		else:
			while event is DialogueEvent:
				event=event.prev
	if !event:
		active="None"
		return
	if event.next:
		var nextevent=event
		var index=events.find(event)
		while nextevent.next:
			if nextevent.prerequisite is TriggerEvent and events.find(nextevent.prerequisite)<index:
				nextevent.prerequisite.dont_skip=true
			nextevent=nextevent.next
	if event.prev:
		event.prev.skip(true)
	event.activate()
	#for end in npc_endings:
		#end.delete_npc()
	print("activated "+loaded_name+" from load")
