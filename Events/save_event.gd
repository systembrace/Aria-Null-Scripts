extends Event
class_name SaveEvent

func activate():
	super.activate()
	main.save_data()
	complete()
