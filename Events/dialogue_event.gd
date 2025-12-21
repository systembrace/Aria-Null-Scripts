extends Event
class_name DialogueEvent

@export var interrupt=false
@export var interruptable=true
@export var change_on_death=-1
@export var loop_last=false
var heard_name
var play_number

func activate():
	heard_name=main.scene_name+"_"+name
	if change_on_death>=0:
		play_number=Global.get_permanent_data("heard_dialogue",heard_name)
	if (change_on_death>=0 and play_number!=null and (play_number>change_on_death or change_on_death==0)) or branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	if active or completed or skipped:
		return
	if !main.is_node_ready():
		await main.ready
	print("playing dialogue "+name)
	super.activate()
	var dialogue_name=name
	if play_number!=null and play_number<=change_on_death:
		if play_number!=change_on_death or !loop_last:
			play_number+=1
		dialogue_name+=str(play_number)
	if !play_number and change_on_death>=0:
		Global.set_permanent_data("heard_dialogue",heard_name,0)
	elif play_number and play_number<=change_on_death:
		Global.set_permanent_data("heard_dialogue",heard_name,play_number)
	main.inventory.hud.dialogue(main.scene_name,dialogue_name,coroutine,interrupt,interruptable,change_on_death,loop_last)
	Global.dialogue_ended.connect(dialogue_ended)

func dialogue_ended():
	print("dialogue "+name+" ended")
	if coroutine:
		finish_task()
	else:
		complete()
	Global.dialogue_ended.disconnect(dialogue_ended)
