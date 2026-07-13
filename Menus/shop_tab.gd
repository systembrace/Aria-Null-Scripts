extends MenuTab
class_name ShopTab

@export var renting=false
@export var checkpoint=false
signal bought_something
var purchasefuncs = {"Nanos":buy_nano,"Shotgun":buy_secondary}
var sellfuncs = {"Nanos":sell_nano}
var secondaries = ["Shotgun"]
var inventoryvar = {"Nanos":"heals"}
var inventoryvarmax = {"Nanos":"maxheals"}
var player: Player
var selected: ShopItem
@onready var items = $HBoxContainer/VScrollBar/ItemList
@onready var description = $HBoxContainer/Description
@onready var purchase = $HBoxContainer2/Purchase
@onready var sell = $HBoxContainer2/Sell

func _ready():
	for child in get_children():
		if child is ShopItem:
			child.reparent(items)
			child.pressed.connect(item_selected.bind(child))
	purchase.disabled=true
	purchase.pressed.connect(purchase_selected)
	if !Global.endless:
		sell.hide()
	sell.disabled=true
	sell.pressed.connect(sell_selected)
	if renting:
		$Rent.show()
	elif !checkpoint:
		$Buy.show()
	elif !Global.endless:
		$Refill.show()

func update_item_availability():
	for item in items.get_children():
		if !item.rented and !item.increase_max and item.name in Global.items_list and !Global.get_flag(item.name):
			item.hide()
		else:
			item.show()

func get_item_count(item=selected):
	if !item.name in inventoryvar:
		return player.inventory.find_child(item.name).num
	else:
		return player.inventory.get(inventoryvar[item.name])

func get_item_max(item=selected):
	if !item.name in inventoryvarmax:
		if Global.endless:
			return player.inventory.find_child(item.name).limit
		return player.inventory.find_child(item.name).max_amt
	else:
		if Global.endless:
			return 3
		var amt=player.inventory.get(inventoryvarmax[item.name])
		if amt==0:
			return 1
		else:
			return amt

func get_item_limit(item=selected):
	if !item.name in inventoryvarmax:
		return player.inventory.find_child(item.name).limit
	else:
		return 10

func item_selected(item):
	selected=item
	description.text=selected.description
	description.show()
	var cost=selected.cost
	var item_count=0
	var item_max=0
	if not item.name in secondaries:
		item_count=get_item_count()
		item_max=get_item_max()
		if item.increase_max:
			item_count=item_max
			item_max=get_item_limit()
	if item.costs_credits or ((!item.name in secondaries or Global.get_flag("Rental_"+item.name)) and is_instance_valid(player) and cost>player.inventory.scrap or ((!item.rented and item_count>=item_max) or (item.rented and (item_count<item_max) or item_count>=item_max+5))):
		back_sfx.emit()
		purchase.disabled=true
	else:
		select_sfx.emit()
		purchase.disabled=false
	if item.name in secondaries or (!item.rented and item_count>0) or (item.rented and item_count<=item_max):
		sell.disabled=false
	else:
		sell.disabled=true

func purchase_selected():
	if visible and is_instance_valid(selected) and is_instance_valid(player):
		var cost=selected.cost
		var itemname=selected.name
		var result
		if !itemname in inventoryvar.keys() and !itemname in secondaries:
			result = buy_item(cost,itemname,selected.rented,selected.increase_max)
		else:
			result = purchasefuncs[itemname].call(cost,itemname,selected.rented)
		if not result:
			back_sfx.emit()
			return
		sell.disabled=false
		if cost>player.inventory.scrap:
			purchase.disabled=true
		select_sfx.emit()

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
		select_sfx.emit()
		
func buy_nano(cost,_name,_rented=false):
	if ((player.inventory.heals<player.inventory.maxheals or player.inventory.maxheals==0) and !Global.endless) or (Global.endless and player.inventory.heals<3):
		player.inventory.heals+=1
		if player.inventory.maxheals==0 and !Global.endless:
			player.inventory.maxheals+=1
		player.inventory.scrap-=cost
		if (not Global.endless and player.inventory.heals>=player.inventory.maxheals) or (Global.endless and player.inventory.heals>=3):
			purchase.disabled=true
		bought_something.emit()
		return true
	return false
	
func sell_nano(cost):
	if player.inventory.heals>0:
		player.inventory.heals-=1
		player.inventory.scrap+=cost

func buy_item(cost,item,rented=false,increase_max=false):
	var item_num=get_item_count()
	var item_max=get_item_max()
	if increase_max or Global.endless:
		item_num=item_max
		if Global.endless:
			item_num=get_item_count()
		item_max=get_item_limit()
	if (!rented and item_num+1<item_max) or (rented and item_num+1<item_max+5):
		player.inventory.find_child(item).num+=1
		if increase_max or Global.endless:
			player.inventory.increase_max(item)
		player.inventory.scrap-=cost
		if (!rented and item_num+1>=item_max) or (rented and item_num+1>=item_max+5):
			purchase.disabled=true
		bought_something.emit()
		return true
	return false

func sell_item(cost,item):
	if player.inventory.find_child(item).num>0:
		player.inventory.find_child(item).num-=1
		player.inventory.find_child(item).max_amt-=1
		player.inventory.scrap+=cost

func buy_secondary(cost,item,rented=false):
	if !rented:
		return
	player.inventory.find_child("Rental"+item).buy()
	player.inventory.scrap-=cost
	bought_something.emit()

func exit_tab():
	open=false
	selected=null
	purchase.disabled=true
	sell.disabled=true
	description.text=""
	description.hide()
	for item in items.get_children():
		item.button_pressed=false

func _process(_delta):
	if !open:
		return
	if !player:
		open=false
		return
	for item in items.get_children():
		if !item.name in secondaries:
			item.num.text=str(get_item_count(item))+"/"+str(get_item_max(item))
		elif len(item.num.text)>0:
			item.num.text=""
