extends AnimatedSprite2D

var ammo
var numshots
var dividers=[]
var inventory: Inventory
var shake=0
var shake_offset=Vector2.ZERO
@onready var full=$Full
@onready var basedivider=$Divider
@onready var count=$CBack/MarginContainer/Count
	
func init_dividers():
	for divider in dividers:
		remove_child(divider)
	dividers.clear()
	ammo=-1
	numshots=inventory.numshots
	var dx=60.0/numshots
	for i in range(1,numshots):
		var divider=basedivider.duplicate()
		add_child(divider)
		divider.position.x=dx-1
		dx+=60.0/numshots
		divider.visible=true
		dividers.append(divider)

func _process(delta):
	if not inventory:
		return
	if !Global.get_flag("roly_poly"):
		hide()
		return
	elif not inventory.secondary:
		show()
		$TrueAmmo.scale.x=floor(inventory.ammo)
		animation="none"
		$Backdrop.scale.y=3
		$Empty.hide()
		full.hide()
		for divider in dividers:
			divider.hide()
		$CBack.hide()
		return
	elif animation=="none":
		$Backdrop.scale.y=11
		$Empty.show()
		full.show()
		for divider in dividers:
			divider.show()
		$CBack.show()
		get_parent().visible=true
	if shake>0:
		shake-=delta
		shake_offset=Vector2(randi_range(-1,1),randi_range(-1,1))
	elif shake_offset!=Vector2.ZERO:
		shake_offset=Vector2.ZERO
	position=Vector2(30,17)+shake_offset
	
	$TrueAmmo.scale.x=floor(inventory.ammo)
	
	if numshots!=inventory.numshots:
		init_dividers()
	if ammo==inventory.ammo:
		return
	
	ammo=floor(inventory.ammo/(60.0/numshots))
	full.scale.x=ammo*60.0/numshots
	count.text=str(int(ammo))
	if (ammo==numshots):
		animation="full"
	elif (ammo==0):
		animation="empty"
	else:
		animation="half"
	
	if ammo>1:
		for i in range(0,ammo):
			dividers[i-1].animation="full"
	if ammo==numshots:
		return
	dividers[ammo-1].animation="half"
	if inventory.ammo>ammo*60/numshots:
		dividers[ammo-1].animation="full"
	if ammo<numshots:
		for i in range(ammo+1,numshots):
			dividers[i-1].animation="empty"
