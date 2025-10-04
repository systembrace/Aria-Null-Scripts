extends VBoxContainer
class_name HelpDesk

var anims=[
	"   ...   ",
	"     ... ",
	"      ...",
	".      ..",
	"..      .",
	"...      ",
	" ...     "
]
var pings=0
signal finished_connecting
@onready var connect_button=$MarginContainer/CenterContainer/Connect
@onready var status=$MarginContainer/CenterContainer/Status
@onready var static_effect=$MarginContainer/Static
@onready var timer=$Timer
@onready var select=$Select
@onready var back=$Back

func _ready():
	hidden.connect(reset)
	timer.wait_time=.2
	timer.timeout.connect(move_anim)
	connect_button.pressed.connect(try_connect)
	
func reset():
	connect_button.show()
	status.hide()
	status.text=""
	static_effect.hide()
	timer.stop()

func try_connect():
	timer.start()
	connect_button.hide()
	status.show()

func move_anim():
	status.text=anims[pings%len(anims)]
	pings+=1
	
func _process(_delta):
	if pings>15:
		timer.stop()
		status.text="Connection failed."
		static_effect.show()
		pings=0
		finished_connecting.emit()
