extends Control
class_name ShopMenu

signal exited
var player
var bought_something
var talked=false
var tabs:Array[MenuTab]=[]
@onready var tab_container:TabContainer=$PanelContainer/MarginContainer/VBoxContainer/TabContainer
@onready var select=$Select
@onready var back=$Back

func _ready():
	tab_container.tab_changed.connect(change_tab)
	for child in get_children():
		if child is MenuTab:
			child.reparent(tab_container)
			child.select_sfx.connect(select.play)
			child.back_sfx.connect(back.play)
			tabs.append(child)
			if child is ShopTab:
				child.bought_something.connect(set.bind("bought_something",true))
			if child is TalkTab:
				child.talked.connect(set.bind("talked",true))

func change_tab(index):
	if len(tabs)==0:
		return
	for i in range(0,len(tabs)):
		if i!=index:
			tabs[index].exit_tab()
	var open_tab=tabs[index]
	open_tab.open=true
	if open_tab is ShopTab:
		open_tab.player=player
	

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
		player.inventory.call_deferred("set","in_shop",false)
		player=null
		exited.emit()

func set_player(node):
	player=node
	for tab in tabs:
		if tab is ShopTab:
			tab.player=player

func _process(_delta):
	if !visible:
		return
	player.inventory.in_shop=true
	player.inventory.hud.scrapicon.show()
	if !player.inventory.hud.scrapicon.find_child("Timer").is_stopped():
		player.inventory.hud.scrapicon.find_child("Timer").stop()
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("inventory"):
		exit_menu(Input.is_action_just_pressed("inventory"))
		talked=false
		return
