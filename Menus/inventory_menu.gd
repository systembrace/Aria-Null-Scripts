extends Control
class_name InventoryMenu

var inventory: Inventory
@onready var guns=$PanelContainer/MarginContainer/VBoxContainer/GunsContainer/Guns
@onready var items=$PanelContainer/MarginContainer/VBoxContainer/ItemsContainer/Items
@onready var revive=$PanelContainer/MarginContainer/VBoxContainer/ReviveContainer/Revive

func _ready():
	guns.item_selected.connect(equip_gun)
	items.item_selected.connect(equip_item)
	revive.item_selected.connect(equip_revival)

func init_options(list,option_menu,amt=false):
	var id=0
	for element in list:
		if Global.get_flag(element.name):
			option_menu.add_icon_item(load("res://Assets/Art/HUD/inventory/"+element.name.to_lower()+".png"),element.name,id)
			if amt:
				option_menu.set_item_text(id,element.name+" x"+str(element.num))
			id+=1

func reset():
	guns.clear()
	init_options(inventory.secondaries,guns)
	guns.selected=inventory.secondaryindex
	items.clear()
	init_options(inventory.items,items,true)
	items.selected=inventory.itemindex
	revive.clear()
	var id=0
	for enemy in Global.revives_list:
		if enemy=="none":
			#revive.add_icon_item(load("res://Assets/Art/HUD/inventory/"+enemy+".png"),inventory.revivenames[enemy],id)
			#id+=1
			continue
		if Global.get_flag(enemy):
			revive.add_icon_item(load("res://Assets/Art/HUD/inventory/"+enemy+".png"),inventory.revivenames[enemy],id)
			id+=1
	if inventory.revival!="none":
		revive.selected=Global.revives_list.find(inventory.revival)
	else:
		revive.selected=0
		inventory.revival=Global.revives_list[0]
	if guns.item_count==0:
		$PanelContainer/MarginContainer/VBoxContainer/GunsContainer.hide()
	else:
		$PanelContainer/MarginContainer/VBoxContainer/GunsContainer.show()
	if items.item_count==0:
		$PanelContainer/MarginContainer/VBoxContainer/ItemsContainer.hide()
	else:
		$PanelContainer/MarginContainer/VBoxContainer/ItemsContainer.show()
	if revive.item_count==0:
		$PanelContainer/MarginContainer/VBoxContainer/ReviveContainer.hide()
	else:
		$PanelContainer/MarginContainer/VBoxContainer/ReviveContainer.show()

func equip_gun(index):
	var sec_name=guns.get_item_text(index)
	var i=0
	for sec in inventory.secondaries:
		if sec.name==sec_name:
			inventory.secondaryindex=i
			inventory.equip_secondary()
			return
		i+=1

func equip_item(index):
	var sec_name=guns.get_item_text(index)
	var i=0
	for sec in inventory.items:
		if sec.name==sec_name:
			inventory.itemindex=i
			inventory.equip_item()
			return
		i+=1

func equip_revival(index):
	inventory.revival=Global.revives_list[index]

func _process(_delta):
	if visible:
		if Input.is_action_just_pressed("inventory"):
			inventory.resume()
			$SFXBack.play()
		if Input.is_action_just_pressed("pause"):
			inventory.resume()
			inventory.open_pause_menu()
