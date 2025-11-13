extends Node2D
class_name Event

@export var prerequisite: Event
@export var coroutine=false
@export var early_skip=false
@export var should_branch=false
@export var interrupt_waypoint_when_branched=false
@export var only_branch_here_backwards=false
@export var branch_when_skipped: Event
@export var ignore_when_event_completed: Event
signal activated
signal just_completed
signal task_finished
signal sequence_finished
var next: Event
var prev: Event
var active=false
var branch=false
var branched_here=false
var skipped=false
var branched_successfully=false
var main
var waiting=false
var completed=false
var coroutine_done=true
var dont_skip=false

func reset():
	active=false
	branch=should_branch
	branched_here=false
	skipped=false
	branched_successfully=false
	waiting=prerequisite!=null
	completed=false
	coroutine_done=false
	dont_skip=false

func _ready():
	branch=should_branch
	main=get_tree().get_root().get_node("Main")
	if prerequisite:
		waiting=true
		prerequisite.task_finished.connect(finish_waiting)

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	branch=should_branch
	active=true
	completed=false
	coroutine_done=!coroutine
	activated.emit(name)
	if coroutine or (prerequisite and prerequisite.completed):
		complete()

func finish_waiting():
	print("finished waiting")
	waiting=false
	if active:
		complete()

func complete():
	if early_skip and !prev.completed:
		skip()
		return
	if branch and branch_when_skipped and !prev.completed:
		branch=false
		skip()
		return
	if completed or !active or waiting:
		return
	if coroutine:
		print(name+" completed via coroutine")
	else:
		print(name+" completed")
	completed=true
	active=false
	just_completed.emit()
	if next and !skipped:
		next.activate()
	elif !next and not get_parent() is RepeatingEvent:
		print("finished with all events!")
		sequence_finished.emit()

func finish_task():
	if !prev.completed and early_skip:
		skip()
		return
	task_finished.emit()
	coroutine_done=true

func catch_up():
	pass
	
func branch_here(branched_from=null):
	if only_branch_here_backwards and !completed:
		return
	if !branched_from and ignore_when_event_completed and ignore_when_event_completed.completed:
		return
	print("branched to "+name)
	if prev!=branched_from:
		prev.skip()
	if interrupt_waypoint_when_branched:
		main.current_waypoint=null
	completed=false
	branch=false
	branched_here=true
	active=false
	activate()
	
func skip(trueskip=false):
	if early_skip:
		early_skip=false
	if dont_skip:
		activate()
		dont_skip=false
		if prev:
			prev.skip(trueskip)
		return
	if completed or skipped:
		return
	completed=true
	if prev:
		prev.skip(trueskip)
	completed=false
	print("skipping "+name)
	if trueskip:
		catch_up()
	waiting=false
	skipped=true
	active=true
	complete()
	completed=true
	just_completed.emit()
	active=false
	if coroutine:
		finish_task()
	if branch_when_skipped and !trueskip and !branched_successfully:
		branched_successfully=true
		branch_when_skipped.branch_here(self)
