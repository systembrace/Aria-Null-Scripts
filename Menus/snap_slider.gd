extends HSlider
class_name SnapSlider

@export var snap_point=0
@export var snap_size=10

func _process(_delta):
	if visible:
		if abs(value-snap_point)<snap_size:
			value=snap_point
