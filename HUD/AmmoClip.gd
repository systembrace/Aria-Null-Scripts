extends AnimatedSprite2D

var ammo
var numshots
var dividers=[]
var inventory: Inventory
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

func _process(_delta):
	if not inventory:
		return
	if not inventory.secondary:
		visible=false
		return
	elif not visible:
		visible=true
		get_parent().visible=true
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
