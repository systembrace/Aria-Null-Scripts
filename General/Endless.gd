extends Main
class_name Endless

signal started
var wave:int=0
var wavepoints=0
var add_wave=[1,4,7,15,12]
var possibleenemies={"spider":1,"enemy":3,"gunman":5,"roly_poly":7,"elite":20}
var maxindex=-1
var highscore:int=0
var spawning=false
var begun=false
var play_with_cherry=false
@onready var wavelabel=$CanvasLayer/Control/PanelContainer/MarginContainer/WaveLabel
@onready var labeltimer=$CanvasLayer/Control/PanelContainer/MarginContainer/WaveLabel/Timer

func _ready():
	super._ready()
	labeltimer.wait_time=2
	labeltimer.timeout.connect($CanvasLayer/Control.show)
	labeltimer.timeout.connect($CanvasLayer/Control/PanelContainer.set.bind("position",Vector2(0,243)))
	highscore=Global.get_flag("endlesshs")
	$CanvasLayer/HSLabel.text="BEST: "+str(highscore)
	$CanvasLayer/HSLabel/Backdrop.scale.x=len($CanvasLayer/HSLabel.text)*9+1
	$CanvasLayer/Shop.exited.connect(next_wave)


func open_shop():
	$Panel.disable()
	player=find_child("Player",true,false)
	if !begun:
		begun=true
		started.emit()
		$CanvasLayer/Control.visible=true
		play_with_cherry=Global.load_config("game","arena_with_cherry")
		if play_with_cherry:
			var cherry=load("res://Scenes/Non-enemies/cherry.tscn").instantiate()
			add_child(cherry)
			cherry.global_position=Vector2(248,192)
		next_wave()
		return
	if player.inventory.scrap<3:
		next_wave()
		return
	$CanvasLayer/Shop.visible=true
	$CanvasLayer/Shop.player=player
	player.control.set_deferred("paused",true)

func next_wave():
	spawning=true
	wave+=1
	while maxindex+1<len(add_wave) and wave>=add_wave[maxindex+1]:
		maxindex+=1
	wavepoints=wave*2-1
	if wave==3:
		wavepoints+=1
	$CanvasLayer/Control/PanelContainer.position=Vector2(211,128)
	wavelabel.text="WAVE "+str(wave)
	labeltimer.start()
	if wave-1>highscore and not play_with_cherry:
		highscore=wave-1
		$CanvasLayer/HSLabel.text="BEST: "+str(highscore)
		$CanvasLayer/HSLabel/Backdrop.scale.x=len($CanvasLayer/HSLabel.text)*9+1
		Global.set_flag("endlesshs",highscore)
		Global.save_flags(true)
	save_data(false,true)

func new_enemy(pos,ename="enemy"):
	var scene=load("res://Scenes/Enemies/spawner.tscn")
	var instance=scene.instantiate()
	instance.global_position=pos
	instance.enemy_name=ename
	wavepoints-=possibleenemies[ename]
	call_deferred("add_child",instance)

func load_from_save():
	var file
	if FileAccess.file_exists("user://endless_loadout.dat"):
		file = FileAccess.open("user://endless_loadout.dat", FileAccess.READ)
	else:
		save_data()
		load_from_save()
		return
	for node in get_tree().get_nodes_in_group("to_save"):
		node.free()
	while file.get_position() < file.get_length():
		var json = JSON.new()
		var contents = file.get_line()
		if json.parse(contents) != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", contents, " at line ", json.get_error_line())
			return
		var data = json.data
		if data["name"]=="Endless":
			wave=data["wave"]
			continue
		var node=load(data["path"]).instantiate()
		if node is Player:
			player=node
		node.load_data(data)
		add_child(node)
	file.close()
	Global.load_game=false
	if wave>0:
		wavelabel.text="WAVE "+str(wave+1)
		labeltimer.start()

func can_save():
	return super.can_save() and !play_with_cherry

func save_data(_checkpoint=false,autosave=false,reset=false):
	if play_with_cherry:
		return
	var scrap=0
	if not autosave:
		for child in get_children():
			if child is Scrap:
				scrap+=1
				child.queue_free()
	var data=""
	var inventorydata
	if !reset:
		reset=Global.player_dead
	for node in get_tree().get_nodes_in_group("to_save"):
		if not node is Inventory and not node is Player:
			continue
		if node is Player and not reset:
			var playerdata=node.save_data()
			playerdata["pos_x"]=192
			playerdata["pos_y"]=816
			data+=JSON.stringify(playerdata)+"\n"
		if node is Inventory:
			node.scrap+=scrap
			if node.itemindex==-1:
				node.itemindex=0
			if node.secondaryindex==-1:
				node.secondaryindex=0
			if node.revival=="none":
				node.revival="roly_poly"
			inventorydata = node.save_data()
	if Global.player_dead or wave<1 or reset:
		data+=JSON.stringify({"name":"Endless","wave":0})
		if Global.player_dead or reset:
			data+="\n"+JSON.stringify({"health":5.0,"name":"Player","path":"res://Scenes/Non-enemies/player.tscn","pos_x":192,"pos_y":816,"prevhp":5.0})
		inventorydata["scrap"]=0
		inventorydata["grenades"]=0
		inventorydata["grenadesmax"]=0
		inventorydata["earthshaker"]=0
		inventorydata["earthshakermax"]=0
		inventorydata["heals"]=0
		inventorydata["maxheals"]=0
		inventorydata["ammo"]=60.0
	elif not spawning:
		data+=JSON.stringify({"name":"Endless","wave":wave})
	else:
		data+=JSON.stringify({"name":"Endless","wave":max(wave-1,0)})
	data+="\n"+JSON.stringify(inventorydata)+"\n"
	Global.saving.emit()
	var file = FileAccess.open("user://endless_loadout.dat", FileAccess.WRITE)
	file.store_string(data)
	file.close()
	Global.save_options(autosave)

func _process(_delta):
	if not begun:
		return
	if num_enemies()==0 and not spawning:
		if wave%3!=0:
			next_wave()
		elif !$CanvasLayer/Shop.visible:
			$Panel/CollisionShape2D.set_deferred("disabled",false)
			$Panel.turn_on()
	if wavepoints>0 and spawning:
		var pos=Vector2(randi_range(0,23),randi_range(0,23))*16+Vector2(8,8)
		$CheckCollision.position=pos
		if $CheckCollision.move_and_slide():
			return
		var enemyindex=randi_range(0,maxindex)
		if wave==add_wave[maxindex]:
			enemyindex=maxindex
		var possible=possibleenemies.keys()[enemyindex]
		if possibleenemies[possible]<=wavepoints:
			new_enemy(pos,possible)
			if wave==add_wave[enemyindex]:
				wavepoints=0
	elif wavepoints<=0:
		spawning=false
