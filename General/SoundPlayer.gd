extends Node2D
class_name SoundPlayer

@export var amt=.01
@export var pitchlevel=1.0
@export var db=0.0
@export var time_between_plays=0.0
@export var free_when_finished=false
@export var loop=false
signal finished
var sounds=[]
var fade=false
var fade_temp=false
var fade_scale=1
var timer: Timer
var time_scale=1.0
var pitch_scale=1.0
var init_db=0
@onready var global_volume=Global.load_config("audio","sfx")+Global.load_config("audio","master")

func _ready():
	init_db=db
	if time_between_plays>0:
		timer=find_child("Timer")
		timer.wait_time=time_between_plays
	for child in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			sounds.append(child)
			child.finished.connect(finish)
			if loop:
				child.finished.connect(play)
			child.volume_db=db+Global.load_config("audio","sfx")+Global.load_config("audio","master")

func get_length():
	return sounds[0].stream.get_length()

func get_playback_position():
	for sound in sounds:
		if sound.playing:
			return sound.get_playback_position()
	return 0

func is_playing():
	for sound in sounds:
		if sound.playing:
			return true
	return false

func set_volume(vol=-99):
	if vol!=-99:
		db=vol
		init_db=db
	for sound in sounds:
		sound.volume_db=db+global_volume

func play(playback_position=0, temp_db=0):
	if fade_temp:
		set_volume(init_db)
		fade_temp=false
		fade=false
	if time_between_plays==0 or timer.is_stopped():
		var sound=sounds[randi_range(0,len(sounds)-1)]
		sound.pitch_scale=(randf_range(-amt,amt)+pitchlevel)*pitch_scale
		sound.volume_db=db+temp_db+global_volume
		if playback_position==-1:
			sound.play(randf_range(0,get_length()))
		else:
			sound.play(playback_position)
		if time_between_plays>0:
			timer.start()

func temp_fade(new_scale=4):
	if !is_playing():
		return
	fade=true
	fade_temp=true
	fade_scale=new_scale

func stop():
	for sound in sounds:
		if sound.is_playing():
			sound.stop()

func finish():
	finished.emit()
	if free_when_finished:
		queue_free()

func _process(delta):
	if time_scale!=Engine.time_scale:
		var diff=(Engine.time_scale-time_scale)/2
		pitch_scale+=diff
		time_scale=Engine.time_scale
	#elif time_scale==1.0 and sounds[0].pitch_scale!=1.0:
	#	for sound in sounds:
	#		sound.pitch_scale=1.0
	
	if fade and db>-60:
		db-=delta*12*fade_scale
		set_volume()
	elif fade:
		if fade_temp:
			stop()
			set_volume(init_db)
			fade_temp=false
			fade=false
			fade_scale=1
		else:
			queue_free()
	if global_volume!=Global.load_config("audio","sfx")+Global.load_config("audio","master"):
		global_volume=Global.load_config("audio","sfx")+Global.load_config("audio","master")
		set_volume()
