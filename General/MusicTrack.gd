extends Node
class_name MusicTrack

@export var autoplay=true
@export var loop=true
@export var init_db=0.0
var db=0.0
var pause_offset=0.0
var fading=false
var calm_db=0.0
var combat_db=-64.0
var base: AudioStreamPlayer
var calm: AudioStreamPlayer
var combat: AudioStreamPlayer

func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	base=find_child("Base")
	calm=find_child("Calm")
	combat=find_child("Combat")
	if loop:
		base.finished.connect(play)
	if autoplay:
		call_deferred("load_track")

func update_volume():
	db=init_db+Global.load_config("audio","music")
	base.volume_db=db+pause_offset
	if calm:
		calm.volume_db=db+calm_db+pause_offset
	if combat:
		combat.volume_db=db+combat_db+pause_offset

func load_track():
	Music.insert(self)

func play():
	db=init_db+Global.load_config("audio","music")
	update_volume()
	base.play()
	if calm:
		calm.play()
	if combat:
		combat.play()

func fade_out():
	fading=true

func stop():
	base.stop()
	if calm:
		calm.stop()
	if combat:
		combat.stop()

func _process(delta):
	if fading:
		init_db=move_toward(init_db,-64,60*delta)
	if init_db<=-32:
		stop()
		queue_free()
	
	if get_tree().paused and pause_offset==0.0 and not get_parent() is OptionsMenu:
		pause_offset=-7.0
	elif !get_tree().paused and pause_offset!=0.0:
		pause_offset=0.0

	if Global.in_combat and (combat_db<0 or calm_db>-64):
		combat_db=move_toward(combat_db,0,3*60*delta)
		calm_db=move_toward(calm_db,-64,3*60*delta)
		update_volume()
	elif !Global.in_combat and (calm_db<0 or combat_db>-64):
		calm_db=move_toward(calm_db,0,5*delta)
		combat_db=move_toward(combat_db,-64,5*delta)
		update_volume()
	elif db!=init_db+Global.load_config("audio","music"):
		update_volume()
