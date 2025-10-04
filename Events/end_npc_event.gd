extends Event
class_name EndNPCEvent

@export var NPC_name="Cherry"

func activate():
	if active or completed:
		delete_npc()
		return
	print("End event reached for "+NPC_name)
	super.activate()
	complete()

func delete_npc():
	for child in main.get_children():
		if child.name==NPC_name:
			child.queue_free()
			print("deleted "+NPC_name)

func skip(trueskip=false):
	super.skip(trueskip)
	if trueskip:
		delete_npc()
