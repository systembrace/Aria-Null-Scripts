extends AnimatedSprite2D

var ammo
var numshots
var dividers=[]
var inventory: Inventory
var shake=0
var shake_offset=Vector2.ZERO
@onready var full=$Secondary/Full
@onready var basedivider=$Divider
@onready var count=$Secondary/CBack/MarginContainer/Count
	
func init_dividers():
	for divider in dividers:
		$Secondary.remove_child(divider)
	dividers.clear()
	ammo=-1
	numshots=inventory.numshots
	var dx=60.0/numshots
	for i in range(1,numshots):
		var divider=basedivider.duplicate()
		$Secondary.add_child(divider)
		divider.position.x=dx-1
		dx+=60.0/numshots
		divider.visible=true
		dividers.append(divider)

func _process(delta):
	if not inventory:
		return
	if inventory.secondary:
		show()
		$Backdrop.scale.y=11
		$Secondary.show()
		get_parent().visible=true
	else:
		var has_revive=false
		for enemy in Global.revives_list:
			if enemy=="none":
				continue
			if Global.get_flag(enemy):
				has_revive=true
				break
		if has_revive:
			show()
			$TrueAmmo/TrueAmmo.scale.x=floor(inventory.ammo)
			animation="none"
			$Secondary.hide()
			$Backdrop.scale.y=3
		else:
			hide()
			$TrueAmmo.hide()
			$Secondary.hide()
			animation="none"
			return
		
	if shake>0:
		shake-=delta
		shake_offset=Vector2(randi_range(-1,1),randi_range(-1,1))
	elif shake_offset!=Vector2.ZERO:
		shake_offset=Vector2.ZERO
	position=Vector2(30,17)+shake_offset
	
	$TrueAmmo/TrueAmmo.scale.x=floor(inventory.ammo)
	
	if !inventory.secondary:
		return
	
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
