extends Control

var inventory: Inventory
var names={
	"roly_poly":"",
	"shield":"Energy Shield"
}
var directions={
	"roly_poly":"(PRESS {hologram} TO USE)",
	"shield":"(PRESS {secondary} TO USE)",
}
var descriptions={
	"roly_poly":"Requires stored energy.\n
	\"Looks like this'll help me out... I'll connect Tessa and I. Seems like it'll be more useful if she holds onto it.\"",
	
	"shield":"Requires energy.\n
	\"Hey, looks like I won't have to deflect as much as I thought!\"",
}

func _ready():
	$PanelContainer/MarginContainer/VBoxContainer/Return.pressed.connect(exit)

func display(item_name):
	show()
	get_tree().paused=true
	inventory.player.control.paused=true
	$ItemGet.play()
	item_name=item_name.to_lower()
	var display_name=names[item_name]
	var texture_name="res://Assets/Art/HUD/inventory/"
	var holo_texture
	if item_name in Global.revives_list:
		display_name="Holo-Regenerator: "+inventory.revivenames[item_name]
		texture_name+="regenerator.png"
		holo_texture="res://Assets/Art/HUD/inventory/"+item_name+".png"
	else:
		texture_name+=item_name+".png"
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
