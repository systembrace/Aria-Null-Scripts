extends Node2D

@onready var basepip=$Pip
@onready var baserefill=$Pip/Refill
@onready var basedrip=$Pip/Drip
@onready var basebreak=$Pip/Break
var health: Health
var maxhealth=0
var healthpips={}

func updatepip():
	for i in range(0,health.hp):
		if healthpips[i].animation=="broken" or healthpips[i].animation=="empty":
			var refill=healthpips[i].get_children()[0]
			refill.restart()
			refill.emitting=true
		healthpips[i].animation="full"
	if health.hp!=health.prevhp:
		for i in range(health.hp,health.prevhp):
			if healthpips[i].animation=="full":
				var breakanim=healthpips[i].get_children()[2]
				breakanim.restart()
				breakanim.emitting=true
			healthpips[i].animation="broken"
			healthpips[i].play()
	if health.prevhp!=health.maxhp:
		for i in range(health.prevhp,health.maxhp):
			if healthpips[i].animation=="broken":
				var drip=healthpips[i].get_children()[1]
				drip.restart()
				drip.emitting=true
			healthpips[i].animation="empty"

func hpcountupdated(new_max):
	for i in healthpips:
		healthpips[i].queue_free()
	healthpips.clear()
	for i in range(0,new_max):
		var pip=basepip.duplicate()
		pip.position.x+=13*i
		pip.visible=true
		add_child(pip)
		#pip.add_child(baserefill.duplicate())
		#pip.add_child(basedrip.duplicate())
		#pip.add_child(basebreak.duplicate())
		healthpips[i]=pip
	maxhealth=new_max

func _process(_delta):
	if is_instance_valid(health):
		if maxhealth!=health.maxhp:
			hpcountupdated(health.maxhp)
			updatepip()
