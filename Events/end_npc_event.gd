extends Event
class_name EndNPCEvent

@export var NPC_name="Cherry"

func activate():
	if active or completed:
		delete_npc()
		return
	print("End event reached for "+NPC_name)
	main.npcs.erase(NPC_name)
	super.activate()
	complete()

func delete_npc():
	if NPC_name in main.npcs:
		main.npcs[NPC_name].queue_free()
		main.npcs.erase(NPC_name)
		print("deleted "+NPC_name)

func skip(trueskip=false):
	super.skip(trueskip)
	if trueskip:
		delete_npc()
