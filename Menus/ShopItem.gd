extends Control
class_name ShopItem

@export_multiline var description="Generic description"
@onready var icon=$MarginContainer/HBoxContainer/Icon
@onready var num=$MarginContainer/HBoxContainer/Num
@onready var cost=int($MarginContainer/HBoxContainer/Cost.text)
