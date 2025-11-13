extends CanvasLayer
class_name OptionsMenu

@export var pause_menu=false
@onready var current_menu=$PanelContainer/MarginContainer/OptionsMenu
@onready var sfx_confirm=$SFXConfirm
@onready var sfx_back=$SFXBack

func _ready():
	$PanelContainer/MarginContainer/OptionsMenu/Game.pressed.connect(switch_menus.bind("GameMenu"))
	$PanelContainer/MarginContainer/OptionsMenu/Video.pressed.connect(switch_menus.bind("VideoMenu"))
	$PanelContainer/MarginContainer/OptionsMenu/Keybinds.pressed.connect(switch_menus.bind("KeybindsMenu"))
	$PanelContainer/MarginContainer/OptionsMenu/Audio.pressed.connect(switch_menus.bind("AudioMenu"))
	$PanelContainer/MarginContainer/OptionsMenu/Game.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/OptionsMenu/Video.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/OptionsMenu/Keybinds.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/OptionsMenu/Audio.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/OptionsMenu/Back.pressed.connect(go_back)
	$PanelContainer/MarginContainer/GameMenu/AttackCursor.toggled.connect(attack_cursor_toggled)
	$PanelContainer/MarginContainer/GameMenu/DashCursor.toggled.connect(dash_cursor_toggled)
	$PanelContainer/MarginContainer/GameMenu/ShootCursor.toggled.connect(shoot_cursor_toggled)
	$PanelContainer/MarginContainer/GameMenu/ParticlesContainer/Particles.value_changed.connect(parts_changed)
	$PanelContainer/MarginContainer/GameMenu/DamageValues.toggled.connect(damage_values_toggled)
	$PanelContainer/MarginContainer/GameMenu/Cherry.toggled.connect(cherry_toggled)
	$PanelContainer/MarginContainer/GameMenu/Back.pressed.connect(go_back)
	$PanelContainer/MarginContainer/GameMenu/DeleteSave.pressed.connect(switch_menus.bind("ConfirmDeleteMenu"))
	$PanelContainer/MarginContainer/GameMenu/DeleteSave.pressed.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/ConfirmDeleteMenu/HBoxContainer/Confirm.pressed.connect(delete_save)
	$PanelContainer/MarginContainer/ConfirmDeleteMenu/HBoxContainer/Back.pressed.connect(go_back)
	$PanelContainer/MarginContainer/VideoMenu/WindowMode.item_selected.connect(window_mode_changed)
	$PanelContainer/MarginContainer/VideoMenu/Confirm.pressed.connect(go_back)
	$PanelContainer/MarginContainer/VideoMenu/ShakeContainer/Shake.value_changed.connect(shake_changed)
	$PanelContainer/MarginContainer/VideoMenu/StopContainer/Hitstop.value_changed.connect(hitstop_changed)
	$PanelContainer/MarginContainer/VideoMenu/BrightnessContainer/Brightness.value_changed.connect(brightness_changed)
	$PanelContainer/MarginContainer/KeybindsMenu/HBoxContainer/Reset.pressed.connect(reset_keybinds)
	$PanelContainer/MarginContainer/KeybindsMenu/HBoxContainer/Cancel.pressed.connect(cancel_keybinds)
	$PanelContainer/MarginContainer/KeybindsMenu/HBoxContainer/Confirm.pressed.connect(confirm_keybinds)
	$PanelContainer/MarginContainer/AudioMenu/Confirm.pressed.connect(go_back)
	$PanelContainer/MarginContainer/GameMenu/AttackCursor.button_pressed=Global.load_config("game","attack_to_cursor")
	$PanelContainer/MarginContainer/GameMenu/DashCursor.button_pressed=Global.load_config("game","dash_to_cursor")
	$PanelContainer/MarginContainer/GameMenu/ShootCursor.button_pressed=Global.load_config("game","shoot_to_cursor")
	$PanelContainer/MarginContainer/GameMenu/DamageValues.button_pressed=Global.load_config("game","damage_values")
	$PanelContainer/MarginContainer/GameMenu/Cherry.button_pressed=Global.load_config("game","arena_with_cherry")
	$PanelContainer/MarginContainer/GameMenu/ParticlesContainer/Particles.value=Global.load_config("game","max_particles")/10
	$PanelContainer/MarginContainer/AudioMenu/SFXContainer/SFX.value_changed.connect(sfx_changed)
	$PanelContainer/MarginContainer/AudioMenu/MusicContainer/Music.value_changed.connect(music_changed)
	$PanelContainer/MarginContainer/VideoMenu/WindowMode.selected=Global.load_config("video","window_mode")
	$PanelContainer/MarginContainer/VideoMenu/BrightnessContainer/Brightness.value=Global.load_config("video","brightness")*100
	$PanelContainer/MarginContainer/VideoMenu/ShakeContainer/Shake.value=Global.load_config("video","screenshake")*100
	$PanelContainer/MarginContainer/VideoMenu/StopContainer/Hitstop.value=Global.load_config("video","hitstop")*100
	$PanelContainer/MarginContainer/AudioMenu/SFXContainer/SFX.value=db_to_linear(Global.load_config("audio","sfx")+2.4987)*100
	$PanelContainer/MarginContainer/AudioMenu/MusicContainer/Music.value=db_to_linear(Global.load_config("audio","music")+2.4987)*100
	$PanelContainer/MarginContainer/AudioMenu/SFXContainer/SFX.drag_started.connect(sfx_confirm.play)
	$PanelContainer/MarginContainer/AudioMenu/SFXContainer/SFX.drag_ended.connect(sfx_confirm.play.unbind(1))
	$PanelContainer/MarginContainer/AudioMenu/MusicContainer/Music.drag_started.connect($MusicTest.play)
	$PanelContainer/MarginContainer/AudioMenu/MusicContainer/Music.drag_ended.connect($MusicTest.play.unbind(1))
	if !pause_menu:
		var worldenv=WorldEnvironment.new()
		worldenv.environment=Global.environment
		add_child(worldenv)
		Global.environment_updated.connect(worldenv.set_deferred.bind("environment",Global.environment))

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
	if (pause_menu and menu_name=="GameMenu") or !FileAccess.file_exists("user://last_scene.dat"):
		$PanelContainer/MarginContainer/GameMenu/DeleteSave.disabled=true
	if pause_menu and menu_name=="VideoMenu":
		$PanelContainer/MarginContainer/VideoMenu/SubViewportContainer.visible=false

func open_options():
	visible=true
	switch_menus("OptionsMenu")

func exit_options():
	disable_menu($PanelContainer/MarginContainer/OptionsMenu)
	visible=false

func go_back():
	if current_menu.name!="VideoMenu" and current_menu.name!="AudioMenu" and current_menu.name!="GameMenu":
		sfx_back.play()
	if current_menu.name=="OptionsMenu":
		exit_options()
		return
	elif current_menu.name=="KeybindsMenu":
		$PanelContainer/MarginContainer/KeybindsMenu/ScrollContainer/InputList.reset_bindings()
	elif current_menu.name=="VideoMenu":
		sfx_confirm.play()
		Global.save_options()
	elif current_menu.name=="AudioMenu":
		sfx_confirm.play()
		Global.save_options()
	elif current_menu.name=="GameMenu":
		sfx_confirm.play()
		Global.save_options()
	elif current_menu.name=="ConfirmDeleteMenu":
		switch_menus("GameMenu")
		return
	switch_menus("OptionsMenu")

func window_mode_changed(index):
	Global.save_config("video","window_mode",index)
	Global.change_window_mode()

func brightness_changed(value):
	$PanelContainer/MarginContainer/VideoMenu/BrightnessContainer/Label.text="Brightness "+str(int(value))+"%"
	Global.save_config("video","brightness",value/100.0)
	Global.environment.adjustment_brightness=value/100.0
	Global.environment_updated.emit()

func shake_changed(value):
	$PanelContainer/MarginContainer/VideoMenu/ShakeContainer/Label.text="Screenshake "+str(int(value))+"%"
	Global.save_config("video","screenshake",value/100.0)

func hitstop_changed(value):
	$PanelContainer/MarginContainer/VideoMenu/StopContainer/Label.text="Hitstop "+str(int(value))+"%"
	Global.save_config("video","hitstop",value/100.0)

func sfx_changed(value):
	$PanelContainer/MarginContainer/AudioMenu/SFXContainer/Label.text="Sound effects "+str(int(value))+"%"
	Global.save_config("audio","sfx",linear_to_db(value/100.0)-2.4987)

func music_changed(value):
	$PanelContainer/MarginContainer/AudioMenu/MusicContainer/Label.text="Music "+str(int(value))+"%"
	Global.save_config("audio","music",linear_to_db(value/100.0)-2.4987)

func reset_keybinds():
	sfx_confirm.play()
	$PanelContainer/MarginContainer/KeybindsMenu/ScrollContainer/InputList.reset_bindings(true)

func cancel_keybinds():
	$PanelContainer/MarginContainer/KeybindsMenu/ScrollContainer/InputList.reset_bindings()
	go_back()
	
func confirm_keybinds():
	sfx_confirm.play()
	$PanelContainer/MarginContainer/KeybindsMenu/ScrollContainer/InputList.save_bindings()
	switch_menus("OptionsMenu")

func attack_cursor_toggled(value):
	Global.save_config("game","attack_to_cursor",value)

func dash_cursor_toggled(value):
	Global.save_config("game","dash_to_cursor",value)
	
func shoot_cursor_toggled(value):
	Global.save_config("game","shoot_to_cursor",value)

func parts_changed(value):
	$PanelContainer/MarginContainer/GameMenu/ParticlesContainer/Label.text="Max particles: "+str(int(value*10))
	Global.save_config("game","max_particles",value*10)

func damage_values_toggled(value):
	Global.save_config("game","damage_values",value)

func cherry_toggled(value):
	Global.save_config("game","arena_with_cherry",value)

func delete_save():
	Global.delete_all_save_data()
	sfx_confirm.play()
	switch_menus("GameMenu")

func _process(_delta):
	if visible:
		if current_menu.name=="KeybindsMenu":
			return
		if Input.is_action_just_pressed("back"):
			go_back()
		if pause_menu and Input.is_action_just_pressed("inventory"):
			go_back()
