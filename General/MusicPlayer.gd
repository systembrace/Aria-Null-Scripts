extends Node
class_name MusicPlayer

var db=0.0
var song: MusicTrack

func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS

func insert(track):
	if song and track.name==song.name:
		return
	track.reparent(self)
	if song:
		eject()
	song=track
	song.play()

func eject():
	if !is_instance_valid(song):
		return
	song.fade_out()
	song=null
