extends Event
class_name Waypoint

@export var clear_current=true

func activate():
	if active or completed:
		return
	super.activate()
	main.current_waypoint=self
	print(name+" activated")

func actor_reached(_actor):
	if prerequisite and !prerequisite.completed:
		return
	#print(actor.name+" reached "+name)
	complete()

func complete():
	if !active or waiting or completed:
		return
	if (!next or not next is Waypoint) and clear_current and main.current_waypoint==self:
		main.current_waypoint=null
	super.complete()
