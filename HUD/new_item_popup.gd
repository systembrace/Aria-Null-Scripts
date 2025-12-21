extends Control

var inventory: Inventory
var directions={
	"roly_poly":"(PRESS {hologram} TO USE)"
}
var descriptions={
	"roly_poly":"Creates a controllable hard-light hologram.\n
				When the user's shell is destroyed, the hologram is used to gather sufficient nanomachines for a complete regeneration.\n
				Only one regeneration is possible per charge.",
}

func _ready():
	$PanelContainer/MarginContainer/VBoxContainer/Return.pressed.connect(exit)

func display(item_name):
	show()
	get_tree().paused=true
	inventory.player.control.paused=true
	$ItemGet.play()
	var display_name=""
	var texture_name="res://Assets/Art/HUD/Inventory/"
	var holo_texture
	if item_name in Global.revives_list:
		display_name="Holo-Regenerator: "+inventory.revivenames[item_name]
		texture_name+="regenerator.png"
		holo_texture="res://Assets/Art/HUD/Inventory/"+item_name+".png"
	$PanelContainer/MarginContainer/VBoxContainer/ItemName.text=display_name
	if holo_texture:
		$PanelContainer/MarginContainer/VBoxContainer/Hologram.texture=load(holo_texture)
	$PanelContainer/MarginContainer/VBoxContainer/ItemTexture.texture=load(texture_name)
	var item_dir=Global.format_keybind(directions[item_name])
	$PanelContainer/MarginContainer/VBoxContainer/Directions.text=item_dir
	$PanelContainer/MarginContainer/VBoxContainer/Description.text=descriptions[item_name].to_upper()

func exit():
	hide()
	get_tree().paused=false
	inventory.player.control.paused=false
