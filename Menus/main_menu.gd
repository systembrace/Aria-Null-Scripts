extends CanvasLayer
class_name MainMenu

var options=false
@onready var current_menu=$Control/PanelContainer/MarginContainer/MainMenu
@onready var sfx_confirm=$SFXConfirm
@onready var sfx_back=$SFXBack

func _ready():
	if FileAccess.file_exists("user://last_scene.dat"):
		var lastfile = FileAccess.open("user://last_scene.dat", FileAccess.READ)
		var prevscene=lastfile.get_as_text()
		lastfile.close()
		if "Endless" in prevscene:
			Global.delete_all_save_data()
	Global.endless=false
	Global.load_game=true
	if FileAccess.file_exists("user://last_scene.dat"):
		$Control/PanelContainer/MarginContainer/MainMenu/Start.text="Continue"
	$Control/PanelContainer/MarginContainer/MainMenu/Start.pressed.connect(start_game)
	$Control/PanelContainer/MarginContainer/MainMenu/Endless.pressed.connect(start_game.bind(true))
	$Control/PanelContainer/MarginContainer/MainMenu/Options.pressed.connect(open_options)
	$Control/PanelContainer/MarginContainer/MainMenu/Options.pressed.connect(sfx_confirm.play)
	$Control/PanelContainer/MarginContainer/MainMenu/Quit.pressed.connect(quit)

func disable_menu(node,disabled=true):
	for child in node.get_children():
		if child is Button and child.name!="Start":
			child.disabled=disabled
		if child is HSlider:
			child.editable=not disabled
		elif child is Container:
			disable_menu(child,disabled)

func open_options():
	options=true
	disable_menu($Control/PanelContainer/MarginContainer/MainMenu)
	$Control/PanelContainer/MarginContainer/MainMenu.visible=false
	$OptionsMenu.open_options()

func start_game(endless=false):
	if endless:
		Global.endless=true
	var scene = load("res://Scenes/General/game_start.tscn")
	get_tree().call_deferred("change_scene_to_packed",scene)

func quit():
	if visible:
		get_tree().quit()

func _process(_delta):
	if !visible:
		return
	if !FileAccess.file_exists("user://last_scene.dat"):
		$Control/PanelContainer/MarginContainer/MainMenu/Start.text="New game"
	if !$OptionsMenu.visible and options:
		disable_menu($Control/PanelContainer/MarginContainer/MainMenu,false)
		$Control/PanelContainer/MarginContainer/MainMenu.visible=true
		set_deferred("options",false)
