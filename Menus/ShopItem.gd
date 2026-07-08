@tool
extends Control
class_name ShopItem

@export var item_name="Nanomachines"
@export_multiline var description="Generic description"
@export var texture_name="healing_orb1"
@export var cost=35
@export var costs_credits=false
@onready var icon=$MarginContainer/HBoxContainer/Icon
@onready var num=$MarginContainer/HBoxContainer/Num

func _ready():
	$MarginContainer/HBoxContainer/Name.text=item_name
	$MarginContainer/HBoxContainer/Icon.texture=load("res://Assets/Art/HUD/"+texture_name+".png")
	$MarginContainer/HBoxContainer/Cost.text=str(cost)
	if costs_credits: 
		$MarginContainer/HBoxContainer/Currency.texture=load("res://Assets/Art/HUD/credit.png")
	else:
		$MarginContainer/HBoxContainer/Currency.texture=load("res://Assets/Art/HUD/scrap.png")
