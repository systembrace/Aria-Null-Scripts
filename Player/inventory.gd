extends Node2D
class_name Inventory

var secondaries=[]
var secondaryindex=-1
var secondary: Node2D
var ammo=60.0
var numshots=12

var items = []
var itemindex: int =-1
var item:Node2D
var charge=0

var player: CharacterBody2D
var main
var revivenames={"none":"None","roly_poly":"Roly poly","enemy":"Infected","elite":"Elite Guard"}
var revival="roly_poly"
var maxheals: int = 0
var heals: int = 0
var scrap: int = 0
var just_unpaused=false
@onready var hud=$Camera2D/Hud
@onready var pausemenu=$Camera2D/CanvasLayer/PauseMenu
@onready var inventorymenu=$Camera2D/CanvasLayer/InventoryMenu
@onready var gunsprite=$CanvasLayer/Gun

func _ready():
	$Camera2D/MouseLayer.layer=1025
	main=get_tree().get_root().get_node("Main")
	update_camera()
	pausemenu.resume_game.connect(resume)
	pausemenu.open_inv.connect(open_inventory_menu)
	for child in get_children():
		if child is Secondary:
			secondaries.append(child)
			if child is Shield:
				child.take_hit.connect(consume_ammo)
				child.deactivated.connect(drop_shield)
				#child.parry.connect(gain_ammo)
		elif child is Item:
			items.append(child)
	$CanvasLayer/Gun/Timer.wait_time=.5
	$CanvasLayer/Gun/Timer.timeout.connect(gunsprite.set_deferred.bind("visible",false))
	inventorymenu.inventory=self
	inventorymenu.reset()
	equip_item()
	if !main.is_node_ready():
		await main.ready
	player=main.player
	assign_player()

func update_camera():
	var map_limits=main.tilemap.get_used_rect()
	var camera=$Camera2D
	camera.limit_left=min(map_limits.position.x*16,16*(map_limits.end.x+map_limits.position.x)/2-240)
	camera.limit_right=max(map_limits.end.x*16,16*(map_limits.end.x+map_limits.position.x)/2+240)
	camera.limit_top=min(map_limits.position.y*16,16*(map_limits.end.y+map_limits.position.y)/2-135)
	camera.limit_bottom=max(map_limits.end.y*16,16*(map_limits.end.y+map_limits.position.y)/2+135)

func pause():
	if is_instance_valid(player):
		if player is Player:
			player.control.paused=true
		get_tree().paused=true

func open_pause_menu():
	pause()
	pausemenu.set_deferred("visible",true)
	$Camera2D/CanvasLayer/PauseMenu/SFXConfirm.play()

func open_inventory_menu():
	pause()
	hud.visible=false
	inventorymenu.reset()
	inventorymenu.set_deferred("visible",true)
	inventorymenu.find_child("SFXConfirm").play()

func resume():
	if is_instance_valid(player):
		get_tree().paused=false
		pausemenu.visible=false
		inventorymenu.visible=false
		hud.visible=true
		if player is Player:
			player.control.paused=false

func gain_ammo(area=null,full=false):
	if (not area is Bullet or area.faction=="enemy") and not area is Harpoon:
		if full:
			ammo=min(ammo+20.0,60.0)
		else:
			ammo=min(ammo+20.0/8.0,60.0)

func equip_secondary():
	if not player.original_player:
		return
	if secondaryindex>=0:
		if secondary and secondary is Shield:
			secondary.deactivate()
		secondary=secondaries[secondaryindex]
		if secondary is Shield:
			secondary.durability=ammo
		secondary.equip(player)
		numshots=secondary.numshots
	else:
		secondary=null

func consume_ammo():
	ammo-=60.0/numshots
	if ammo<.5:
		ammo=0

func use_secondary(_amount=10):
	if secondary and secondary is Shield and !Input.is_action_pressed("secondary"):
		secondary.deactivate()
	if not secondary or (floor(ammo*numshots/60)<1 and ((secondary is Grapple and !secondary.deployed) or not secondary is Grapple)) or not secondary.can_use():
		if secondary and (Input.is_action_just_pressed("secondary") or not secondary.can_use()) and floor(ammo*numshots/60)<1:
			$NoAmmo.play()
		return
	if secondary is Shield:
		secondary.durability=ammo
		if !Input.is_action_pressed("secondary"):
			secondary.deactivate()
		elif Input.is_action_just_pressed("secondary"):
			secondary.activate()
			if is_instance_valid(player) and player.hurtbox:
				player.hurtbox.disable_hurtbox()
	else:
		if not secondary is Grapple or (secondary is Grapple and !secondary.deployed):
			consume_ammo()
		secondary.use()

func drop_shield():
	if is_instance_valid(player) and player.hurtbox:
		player.hurtbox.enable_hurtbox()

func refill_items():
	heals=maxheals
	for node in items:
		node.num=node.max_amt

func equip_item():
	if itemindex>=0:
		item=items[itemindex]
		item.equip(player)
	else:
		item=null

func use_item():
	if item:
		item.use(charge)

func assign_player():
	hud.health=player.find_child("Health")
	hud.control=player.find_child("Control")
	hud.inventory=self
	hud.reset()
	player.inventory=self
	if player is Player:
		player.control.inventory=self
		numshots=0
		equip_item()
		if not player.original_player:
			secondary=player.secondary
		else:
			equip_secondary()
			player.secondary=secondary
		if secondary:
			numshots=secondary.numshots

func _process(delta):
	if main.dark and !$Lamp.enabled:
		$Lamp.enabled=true
	elif !main.dark and $Lamp.enabled:
		$Lamp.enabled=false
	if not is_instance_valid(player):
		charge=0
		secondary=null
		for child in main.get_children():
			if child is Player or child is PlayerGhost:
				player=child
				assign_player()
	if is_instance_valid(player):
		gunsprite.position=player.position-$Camera2D.get_screen_center_position()+Vector2.UP*38+Vector2(240,135)
		global_position=player.global_position+Vector2.UP*16
		if (player is Player and !player.control.paused) or not player is Player:
			if Input.is_action_just_pressed("pause"):
				open_pause_menu()
			if Input.is_action_just_pressed("inventory"):
				open_inventory_menu()
		if player is Player and not player.control.paused:
			if itemindex!=-1 and Input.is_action_just_released("next item"):
				itemindex=int(itemindex+1)%items.size()
				while !Global.get_flag(items[itemindex].name):
					itemindex=int(itemindex+1)%items.size()
				equip_item()
				$EquipItem.play()
			if secondaryindex!=-1 and player.original_player and Input.is_action_just_pressed("next gun"):
				secondaryindex=int(secondaryindex+1)%secondaries.size()
				while !Global.get_flag(secondaries[secondaryindex].name):
					secondaryindex=int(secondaryindex+1)%secondaries.size()
				equip_secondary()
				$EquipGun.play()
				gunsprite.animation=secondary.name.to_lower()
				gunsprite.visible=true
				$CanvasLayer/Gun/Timer.start()
		if player is PlayerGhost or player.control.paused or !item or item.num==0:
			#if player is Player:
				#just_unpaused=player.control.paused
			return
		#if just_unpaused:
			#just_unpaused=false
			#if item and item.timer.is_stopped():
			#	item.timer.wait_time=0.01
			#	item.timer.start()
			#	item.set_buffer()
		if Input.is_action_just_released("use item"):
			use_item()
			charge=0
		elif Input.is_action_pressed("use item") and item.timer.is_stopped() and charge<item.chargetime:
			charge+=60*delta
			if charge>=item.chargetime:
				charge=item.chargetime
				$Charge.play()

func save_data():
	var data = {
		"name":"Inventory",
		"path":scene_file_path,
		"heals":heals,
		"maxheals":maxheals,
		"scrap":scrap,
		"revival":revival,
		"grenades":$Grenades.num,
		"grenadesmax":$Grenades.max_amt,
		"earthshaker":$Earthshaker.num,
		"earthshakermax":$Earthshaker.max_amt,
		"ammo":ammo,
		"secondaryindex":secondaryindex,
		"itemindex":itemindex
	}
	return data

func load_data(data):
	add_to_group("to_save")
	if "name" in data.keys():
		name=data["name"]
	if "heals" in data.keys():
		heals=data["heals"]
	if "maxheals" in data.keys():
		maxheals=data["maxheals"]
	if "scrap" in data.keys():
		scrap=data["scrap"]
	if "revival" in data.keys():
		revival=data["revival"]
	if "grenades" in data.keys():
		$Grenades.num=data["grenades"]
	if "grenadesmax" in data.keys():
		$Grenades.max_amt=data["grenadesmax"]
	if "earthshaker" in data.keys():
		$Earthshaker.num=data["earthshaker"]
	if "earthshakermax" in data.keys():
		$Earthshaker.max_amt=data["earthshakermax"]
	if "ammo" in data.keys():
		ammo=data["ammo"]
	if "secondaryindex" in data.keys():
		secondaryindex=data["secondaryindex"]
	if "itemindex" in data.keys():
		itemindex=int(data["itemindex"])
