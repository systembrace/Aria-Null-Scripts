extends Event
class_name RepeatingEvent

@export var loop=false
@export var end_when_completed: Event
@export var start_events:Array[Event]=[]
var current=0

func _ready():
	super._ready()
	var prev_child=get_children()[0]
	if end_when_completed:
		end_when_completed.just_completed.connect(end_repeats)
	if len(start_events)==1:
		prev_child.just_completed.connect(iter_ended)
	for i in range(1,len(get_children())):
		var child=get_children()[i]
		if not child in start_events:
			prev_child.next=child
			prev_child=child
		else:
			prev_child.just_completed.connect(iter_ended)

func activate():
	if branch or (ignore_when_event_skipped and ignore_when_event_skipped.completed):
		active=true
		complete()
		return
	if active or completed or current>=len(start_events):
		return
	super.activate()
	start_events[current].activate()
	
func iter_ended():
	current+=1
	complete()
	#if current!=len(start_events) or loop:
		#completed=false
	if loop and current>=len(start_events):
		print("resetting "+name)
		reset()
		current=len(start_events)-1
		for child in get_children():
			child.reset()
		completed=true

func end_repeats():
	current=len(start_events)
	complete()
	for child in get_children():
		child.complete()

func branch_here(branched_from=null):
	if current>=len(start_events):
		return
	super.branch_here(branched_from)
