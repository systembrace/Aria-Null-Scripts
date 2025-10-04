extends AnimatedSprite2D

var control:PlayerControl
var speed
var accel
var min_speed
var max_speed
var tier=0

func start():
	if control:
		min_speed=control.min_speed
		max_speed=control.max_speed
		speed=control.speed
		accel=control.accel
		tier=0
		animation="0"

func _process(_delta):
	if tier>=5:
		position=Vector2(randi_range(-1,1),randi_range(-1,1))
	if is_instance_valid(control):
		if abs(speed-control.speed)>=accel:
			if control.speed<=min_speed:
				if speed>control.speed:
					animation="1"
					play_backwards()
			else:
				for i in range(0,6):
					if control.speed<=min_speed+accel*i:
						var prev=animation
						animation=str(i)
						if speed<control.speed:
							play()
							tier=i
						elif speed>control.speed:
							animation=str(i+1)
							play_backwards()
							tier=i-1
						else:
							animation=prev
						break
			speed=control.speed
