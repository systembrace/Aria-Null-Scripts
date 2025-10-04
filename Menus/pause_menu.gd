extends Control
class_name PauseMenu

signal resume_game
signal open_inv
var main
var exit=false
var options=false
@onready var current_menu=$PanelContainer/MarginContainer/StartMenu
@onready var sfx_confirm=$SFXConfirm
@onready var sfx_back=$SFXBack

func _ready():
	$PanelContainer/MarginContainer/StartMenu/Resume.pressed.connect(go_back)
	$PanelContainer/MarginContainer/StartMenu/Options.pressed.connect(open_options)
	$PanelContainer/MarginContainer/StartMenu/Options.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/StartMenu/Checkpoint.pressed.connect(switch_menus.bind("CheckpointMenu"))
	$PanelContainer/MarginContainer/StartMenu/Checkpoint.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/StartMenu/Quit.pressed.connect(open_quit)
	$PanelContainer/MarginContainer/StartMenu/Exit.pressed.connect(open_quit.bind(true))
	$PanelContainer/MarginContainer/QuitMenu/HBoxContainer/Quit.pressed.connect(quit)
	$PanelContainer/MarginContainer/QuitMenu/HBoxContainer/Cancel.pressed.connect(go_back)
	$PanelContainer/MarginContainer/CheckpointMenu/HBoxContainer/Confirm.pressed.connect(reset)
	$PanelContainer/MarginContainer/CheckpointMenu/HBoxContainer/Cancel.pressed.connect(go_back)
	main=get_tree().get_root().get_node("Main")

func disable_menu(node,disabled=true):
	for child in node.get_children():
		if child is Button:
			child.disabled=disabled
		if child is HSlider:
			child.editable=not disabled
		elif child is Container:
			disable_menu(child,disabled)

func switch_menus(menu_name):
	var menu=find_child(menu_name)
	current_menu.hide()
	disable_menu(current_menu,true)
	current_menu=menu
	current_menu.show()
	disable_menu(current_menu,false)
	if menu_name=="CheckpointMenu" and Global.endless:
		$PanelContainer/MarginContainer/CheckpointMenu/Label.text="Are you sure you want\nto restart the arena?"

func go_back():
	if options:
		return
	sfx_back.play()
	if current_menu.name=="StartMenu":
		resume()
		switch_menus("StartMenu")
	else:
		switch_menus("StartMenu")

func open_options():
	options=true
	disable_menu($PanelContainer/MarginContainer/StartMenu)
	$PanelContainer.visible=false
	$OptionsMenu.open_options()

func reset():
	Global.reset_to_checkpoint()
	if Global.endless:
		main.save_data(false,false,true)
	main.fade_out()
	get_tree().create_timer(1).timeout.connect(Global.reset_game)

func open_quit(ex=false):
	exit=ex
	if exit:
		$PanelContainer/MarginContainer/QuitMenu/HBoxContainer/Quit.text="Exit"
	else:
		$PanelContainer/MarginContainer/QuitMenu/HBoxContainer/Quit.text="Quit"
	sfx_confirm.play()
	if Global.endless and main.can_save():
		$PanelContainer/MarginContainer/QuitMenu/Label.text="Save and quit?\nYour progress, loadout\nand highscore\nwill be saved."
	elif Global.endless and !main.can_save():
		if main.play_with_cherry:
			$PanelContainer/MarginContainer/QuitMenu/Label.text="Warning:\nYour game will not be\nsaved while playing\nwith Cherry."
		else:
			$PanelContainer/MarginContainer/QuitMenu/Label.text="Warning\nOnly your last cleared\nwave and your highscore\nwill be saved."
	elif main.can_save():
		$PanelContainer/MarginContainer/QuitMenu/Label.text="Save and quit?\nYour progress will\nbe saved."
	else:
		$PanelContainer/MarginContainer/QuitMenu/Label.text="Warning:\nQuitting now will\nnot save the game.\nQuit?"
	switch_menus("QuitMenu")

func resume():
	if visible:
		resume_game.emit()

func quit():
	if visible:
		if main.can_save():
			main.save_data()
		main.fade_out(true)
		var timer=get_tree().create_timer(1)
		timer.timeout.connect(finish_quit)
		$PanelContainer/MarginContainer/StartMenu/Exit.disabled=true

func finish_quit():
	if exit:
		get_tree().paused=false
		var scene = load("res://Scenes/UI/main_menu.tscn")
		get_tree().get_root().call_deferred("remove_child",main)
		get_tree().call_deferred("change_scene_to_packed",scene)
	else:
		get_tree().quit()

func _process(_delta):
	if visible:
		if !$OptionsMenu.visible and options:
			switch_menus("StartMenu")
			set_deferred("options",false)
			$PanelContainer.set_deferred("visible",true)
			return
		if Input.is_action_just_pressed("back"):
			go_back()
		if Input.is_action_just_pressed("inventory"):
			resume_game.emit()
			open_inv.emit()
