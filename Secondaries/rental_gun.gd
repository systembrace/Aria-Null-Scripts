extends Gun
class_name RentalGun

@export var max_shots=15
signal broke
var shots_remaining=0
@onready var inventory:Inventory=get_parent()

func buy():
	Global.set_flag("Rental_"+name,true)
	shots_remaining=max_shots
	inventory.secondaryindex=inventory.secondaries.find(self)
	inventory.equip_secondary()

func use():
	super.use()
	shots_remaining-=1
	if shots_remaining==0:
		rental_break()

func rental_break():
	Global.set_flag("Rental_"+name,false)
	var self_index=inventory.secondaries.find(self)
	var closest_gun=-1
	var min_dist=len(inventory.secondaries)
	for i in range(0,len(inventory.secondaries)):
		if Global.get_flag(inventory.secondaries[i].name) and abs(self_index-i)<min_dist:
			min_dist=abs(self_index-i)
			closest_gun=i
	inventory.secondaryindex=closest_gun
	inventory.equip_secondary()
	broke.emit()
