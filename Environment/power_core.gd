extends Node2D
class_name PowerCore

var step=0

func _process(delta):
	step+=delta*1.25
	if step>PI*2:
		step-=PI*2
	$RodBottom.offset.y=-72+round(sin(step)*2)
	$RodTop.offset.y=-72+round(sin(step)*2)
