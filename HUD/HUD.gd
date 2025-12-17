extends CanvasLayer

var inventory: Inventory
var health: Health
var control: PlayerControl

@onready var portrait=$Portrait
@onready var hpbar=$HPBar
#@onready var speedometer=$Speedometer
@onready var ammoclip=$AmmoClip
@onready var scraplabel=$VBoxContainer/Control2/ScrapIcon/ScrapLabel
@onready var healorb=$HealLabel/HealOrb
@onready var heallabel=$HealLabel
@onready var equipicon=$EquipLabel/EquipIcon
@onready var equiplabel=$EquipLabel
@onready var timer=$SaveIcon/Timer
@onready var itembar=$ItemBar
@onready var scrapicon=$VBoxContainer/Control2/ScrapIcon
@onready var dialogue_box=$Dialogue
@onready var icon=$VBoxContainer/Control/Icon
@onready var item_popup=$NewItemPopup

var scrapframes=0

func _ready():
	Global.saving.connect(show_save)
	timer.wait_time=2
	timer.timeout.connect($SaveIcon.hide)
	$VBoxContainer/Control2/ScrapIcon/Timer.wait_time=5
	$VBoxContainer/Control2/ScrapIcon/Timer.timeout.connect(scrapicon.hide)
	$VBoxContainer/Control2/ScrapIcon/Timer.start()

func hide_all():
	for child in get_children():
		child.hide()

func show_save():
	$SaveIcon.visible=true
	if timer.is_inside_tree():
		timer.start()
	
func hide_save():
	$SaveIcon.visible=false

func reset():
	if health and hpbar:
		hpbar.health=health
		#if not hpbar.updatepip in health.hpchanged.get_connections():
		health.hpchanged.connect(hpbar.updatepip)
		hpbar.hpcountupdated(health.maxhp)
		hpbar.updatepip()
	if ammoclip and inventory:
		ammoclip.inventory=inventory
		ammoclip.init_dividers()
	if inventory:
		item_popup.inventory=inventory
	#if control and speedometer:
	#	speedometer.control=control
	#	speedometer.start()
		
func _process(_delta):
	if is_instance_valid(control):
		if control.healing:
			healorb.position=Vector2(randi_range(-1,1),randi_range(-1,1))
		else:
			healorb.position=Vector2.ZERO
		
	if is_instance_valid(inventory) and is_instance_valid(inventory.player) and inventory.player is Player:
		if inventory.player.original_player and inventory.can_revive and portrait.animation!="default":
			portrait.animation="default"
		elif inventory.player.original_player and !inventory.can_revive and portrait.animation!="norevive":
			portrait.animation="norevive"
		elif !inventory.player.original_player and portrait.animation!=inventory.revival:
			portrait.animation=inventory.revival
		
		var text=scraplabel.text
		if int(text)!=inventory.scrap and "#" not in text and "@" not in text:
			scrapicon.show()
			$VBoxContainer/Control2/ScrapIcon/Timer.start()
			scrapframes=6
		if scrapframes>0:
			if scrapframes>3:
				scraplabel.text=text.substr(0,len(text)-1)+"#"
			else:
				scraplabel.text=text.substr(0,len(text)-1)+"@"
			scrapframes-=1
		else:
			scraplabel.text=str(inventory.scrap)
			$VBoxContainer/Control2/ScrapIcon/ScrapLabel/Backdrop.scale.x=len(scraplabel.text)*9+1
		
		if !Global.endless and inventory.maxheals==0:
			heallabel.hide()
		elif !Global.endless and int(inventory.heals/inventory.maxheals)!=healorb.frame:
			if !heallabel.visible:
				heallabel.show()
			healorb.frame=int(inventory.heals*3/inventory.maxheals)
		elif Global.endless and inventory.heals!=healorb.frame:
			healorb.frame=inventory.heals
		
		if heallabel.text!="x"+str(inventory.heals):
			heallabel.text="x"+str(inventory.heals)
			$HealLabel/Backdrop.scale.x=len(heallabel.text)*9+1
		
		if !inventory.item:
			if equiplabel.visible:
				equiplabel.visible=false
			if itembar.visible:
				itembar.visible=false
		else:
			if !equiplabel.visible:
				equiplabel.visible=true
		
			if !inventory.item.timer.is_stopped():
				itembar.visible=true
				$ItemBar/Fill.scale.y=-((inventory.item.timer.wait_time-inventory.item.timer.time_left)/inventory.item.timer.wait_time)*15
			else:
				itembar.visible=false
		
			if equipicon.animation!=inventory.item.name.to_lower():
				equipicon.animation=inventory.item.name.to_lower()
			if equiplabel.text!="x"+str(inventory.item.num):
				equiplabel.text="x"+str(inventory.item.num)
				$EquipLabel/Backdrop.scale.x=len(equiplabel.text)*9+1
				
			if inventory.item.chargetime>0 and inventory.charge>=inventory.item.chargetime:
				equipicon.position=Vector2(randi_range(-1,1),randi_range(-1,1))
			else:
				equipicon.position=Vector2.ZERO
		
		if inventory.secondary and inventory.secondary is Gun or inventory.secondary is Shield:
			$VBoxContainer/Control.visible=true
			var gun_name=inventory.secondary.name.to_lower()
			icon.animation=gun_name
			$VBoxContainer/Control/Icon/Backdrop.scale.x=icon.sprite_frames.get_frame_texture(gun_name,0).get_width()+2
		else:
			$VBoxContainer/Control.visible=false

func dialogue(scene_name,section,do_timer,pause_player,interrupt,interruptable,change_on_death):
	var data=ConfigFile.new()
	data.load("res://dialogue/"+scene_name+".ini")
	if pause_player:
		dialogue_box.enter(data,section,do_timer,inventory.player.control,interrupt,interruptable,change_on_death)
	else:
		dialogue_box.enter(data,section,do_timer,null,interrupt,interruptable,change_on_death)
