extends Event
class_name RewardEvent

@export var item="scrap"
@export var item_num=1
@export var increase_max=false
var step=0

func activate():
	if active or completed:
		return
	if branch or (ignore_when_event_completed and ignore_when_event_completed.completed and not ignore_when_event_completed.skipped):
		active=true
		complete()
		return
	super.activate()
	if !main.is_node_ready():
		await main.ready
	if item!="scrap":
		main.player.inventory.itemindex=0
		main.player.inventory.equip_item()

func _process(delta):
	step+=60*delta
	if active and step>=1:
		step-=1
		if item=="scrap":
			main.player.control.collect_scrap()
		else:
			main.player.inventory.find_child(item).num+=1
			if increase_max:
				main.player.inventory.increase_max(item)
		item_num-=1
		if item_num<=0:
			complete()
