extends Main
class_name DeathZone

var dialogue: Event

func _ready():
	y_sort_enabled=true
	scene_name="death_zone"
	worldenv=WorldEnvironment.new()
	worldenv.environment=Global.environment
	add_child(worldenv)
	Global.environment_updated.connect(worldenv.set_deferred.bind("environment",Global.environment))
	var canvaslayer=CanvasLayer.new()
	canvaslayer.layer=0
	add_child(canvaslayer)
	transition=load("res://Scenes/General/FadeTransition.tscn").instantiate()
	canvaslayer.add_child(transition)
	
	player=$Player
	inventory=$Inventory
	inventory.player=player
	inventory.assign_player()
	inventory.hud.hide_all()
	
	var death=Global.get_permanent_data("global","deaths")
	
	dialogue=find_child("Death"+str(death))
	#if death<=2:
	dialogue.get_children()[-2].just_completed.connect(fade_out.bind(true,2))
	#else:
	#	dialogue.get_children()[-1].just_completed.connect(fade_out.bind(true,2))
	transition.finished.connect(dialogue.activate)
	transition.faded_out.connect(exit)
	transition.fade_out()

func exit():
	Music.eject(.1)
	Global.set_permanent_data("global","player_dead",false)
	if Global.get_permanent_data("global","deaths")<=3:
		Global.death_cutscene=true
	Global.reset_game()

func _physics_process(_delta):
	if abs(player.position.x)>200:
		player.position.x-=400*sign(player.position.x)
	if abs(player.position.y)>104:
		player.position.y-=208*sign(player.position.y)
