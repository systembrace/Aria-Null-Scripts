extends Control
class_name Shop

var purchasefuncs = {"Nanos":buy_nano}
var sellfuncs = {"Nanos":sell_nano}
var inventoryvar = {"Nanos":"heals"}
var inventoryvarmax = {"Nanos":"maxheals"}
var player: Player
var selected: ShopItem
var tried_connecting=false
var bought_something=false
signal exited
@onready var items = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Supply/HBoxContainer/VScrollBar/ItemList
@onready var description = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Supply/HBoxContainer/Description
@onready var purchase = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Supply/HBoxContainer2/Purchase
@onready var exit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Exit
@onready var sell = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/Supply/HBoxContainer2/Sell
@onready var select = $Select
@onready var back = $Back
@onready var help_desk=$"PanelContainer/MarginContainer/VBoxContainer/TabContainer/Help Desk"

func _ready():
	for item in items.get_children():
		item.pressed.connect(item_selected.bind(item))
		if item.name in Global.items_list and !Global.get_flag(item.name):
			item.hide()
	purchase.disabled=true
	purchase.pressed.connect(purchase_selected)
	exit.pressed.connect(exit_menu)
	if !Global.endless:
		sell.hide()
	sell.disabled=true
	sell.pressed.connect(sell_selected)
	help_desk.finished_connecting.connect(set.bind("tried_connecting",true))

func get_item_count(item=selected):
	if !item.name in inventoryvar:
		if Global.endless:
			return player.inventory.find_child(item.name).num
		return player.inventory.find_child(item.name).max_amt
	else:
		return player.inventory.get(inventoryvar[item.name])

func get_item_max():
	if !selected.name in inventoryvarmax:
		return player.inventory.find_child(selected.name).limit
	else:
		if Global.endless:
			return 3
		var amt=player.inventory.get(inventoryvarmax[selected.name])
		if amt==0:
			return 1
		else:
			return amt

func item_selected(item):
	selected=item
	description.text=selected.description
	description.show()
	var cost=selected.cost
	if is_instance_valid(player) and cost>player.inventory.scrap or get_item_count()>=get_item_max():
		back.play()
		purchase.disabled=true
	else:
		select.play()
		purchase.disabled=false
	if get_item_count()>0:
		sell.disabled=false
	else:
		sell.disabled=true

func purchase_selected():
	if visible and is_instance_valid(selected) and is_instance_valid(player):
		var cost=selected.cost
		var itemname=selected.name
		var result
		if !itemname in inventoryvar.keys():
			result = buy_item(cost,itemname)
		else:
			result = purchasefuncs[itemname].call(cost)
		if not result:
			back.play()
			return
		sell.disabled=false
		if cost>player.inventory.scrap:
			purchase.disabled=true
		select.play()

func sell_selected():
	if visible and is_instance_valid(selected) and is_instance_valid(player):
		var cost=selected.cost
		var itemname=selected.name
		if !itemname in inventoryvar.keys():
			sell_item(cost,itemname)
		else:
			sellfuncs[itemname].call(cost)
		if player.inventory.scrap>=cost:
			purchase.disabled=false
		if get_item_count()==0:
			sell.disabled=true
		select.play()

func exit_menu(immediate=false):
	if visible:
		back.play()
		if !immediate:
			player.inventory.hud.scrapicon.hide()
			player.control.set_deferred("paused",false)
			set_deferred("visible",false)
		else:
			player.control.paused=false
			visible=false
		player=null
		exited.emit()
		for item in items.get_children():
			item.button_pressed=false
		
func buy_nano(cost):
	if ((player.inventory.heals<player.inventory.maxheals or player.inventory.maxheals==0) and !Global.endless) or (Global.endless and player.inventory.heals<3):
		player.inventory.heals+=1
		if player.inventory.maxheals==0 and !Global.endless:
			player.inventory.maxheals+=1
		player.inventory.scrap-=cost
		if (not Global.endless and player.inventory.heals>=player.inventory.maxheals) or (Global.endless and player.inventory.heals>=3):
			purchase.disabled=true
		bought_something=true
		return true
	return false
	
func sell_nano(cost):
	if player.inventory.heals>0:
		player.inventory.heals-=1
		player.inventory.scrap+=cost

func buy_item(cost,item):
	if player.inventory.find_child(item).num+1<=player.inventory.find_child(item).limit:
		player.inventory.find_child(item).num+=1
		player.inventory.find_child(item).max_amt+=1
		player.inventory.scrap-=cost
		if player.inventory.find_child(item).num>=player.inventory.find_child(item).limit:
			purchase.disabled=true
		bought_something=true
		return true
	return false

func sell_item(cost,item):
	if player.inventory.find_child(item).num>0:
		player.inventory.find_child(item).num-=1
		player.inventory.find_child(item).max_amt-=1
		player.inventory.scrap+=cost

func _process(_delta):
	if !visible:
		return
	player.inventory.hud.scrapicon.show()
	if !player.inventory.hud.scrapicon.find_child("Timer").is_stopped():
		player.inventory.hud.scrapicon.find_child("Timer").stop()
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("inventory"):
		exit_menu(Input.is_action_just_pressed("inventory"))
		selected=null
		purchase.disabled=true
		sell.disabled=true
		description.text=""
		description.hide()
		tried_connecting=false
		return
	for item in items.get_children():
		item.num.text="x"+str(get_item_count(item))
