@tool
extends Control
class_name ShopItem

@export var item_name="Nanomachines"
@export_multiline var description="Generic description"
@export var texture_name="healing_orb1"
@export var price:float=35
@export var costs_credits=false
@export var rented=false
@export var increase_max=false
var main: Main
@onready var cost=round(price)
@onready var icon=$MarginContainer/HBoxContainer/Icon
@onready var num=$MarginContainer/HBoxContainer/Num

func _ready():
	if !Engine.is_editor_hint():
		main=get_tree().get_root().get_node("Main")
	$MarginContainer/HBoxContainer/Name.text=item_name
	$MarginContainer/HBoxContainer/Icon.texture=load("res://Assets/Art/HUD/"+texture_name+".png")
	$MarginContainer/HBoxContainer/Cost.text=str(int(cost))
	if costs_credits: 
		$MarginContainer/HBoxContainer/Currency.texture=load("res://Assets/Art/HUD/credit.png")
	else:
		$MarginContainer/HBoxContainer/Currency.texture=load("res://Assets/Art/HUD/scrap.png")

func _process(_delta):
	if Engine.is_editor_hint():
		return
	if !visible or !increase_max:
		return
	var max_amt=main.inventory.maxheals
	if name!="Nanos":
		max_amt=main.inventory.find_child(name).max_amt
	max_amt+=1
	if cost!=round(price*max_amt):
		cost=price*max_amt
		$MarginContainer/HBoxContainer/Cost.text=str(int(cost))
