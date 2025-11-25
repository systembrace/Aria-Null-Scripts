extends Interactable

var main
var can_refill=true
signal exited_without_connecting
signal exited_with_connecting
signal bought_something
signal didnt_buy
@onready var shop=$CanvasLayer/Shop

func _ready():
	super._ready()
	main = get_tree().get_root().get_node("Main")
	await main.ready
	if Global.endless:
		if main.wave>0:
			deactivate()
	if main.scene_file_path==Global.checkpoint_scene or (Global.endless and main.wave>0):
		disable_refill()
	if !main.dark:
		$PointLight2D.energy=.5
		$Glowy/GlowLight.hide()
	else:
		$Glowy/GlowLight.show()
	$CanvasLayer/Shop.exited.connect(exit_shop)

func disable_refill():
	can_refill=false
	$PointLight2D.texture_scale=2
	$Glowy.animation="small"
	$Swirl.emitting=true
	$Swirl2.emitting=true

func interact(player):
	if !can_interact:
		return
	if player.original_player:
		save_data()
		if can_refill:
			player.control.health.heal()
			player.control.inventory.ammo=60
			player.control.inventory.refill_items()
			$Activate.emitting=true
			disable_refill()
		player.control.set_deferred("paused",true)
		$CanvasLayer/Shop.player=player
		$CanvasLayer/Shop.set_deferred("visible",true)
	else:
		var new_player=load("res://Scenes/Allies/player.tscn").instantiate()
		main.add_child(new_player)
		new_player.global_position=player.global_position
		player.free()
		call_deferred("interact",new_player)

func exit_shop():
	if shop.tried_connecting:
		exited_with_connecting.emit()
	else:
		exited_without_connecting.emit()
	if shop.bought_something:
		bought_something.emit()
	else:
		didnt_buy.emit()
	shop.tried_connecting=false
	shop.bought_something=false
	save_data()

func save_data():
	main.save_data(true)
	#if $Glowy.animation!="small" and main.scene_file_path==Global.checkpoint_scene:
		#disable_refill()
