extends Main
class_name CombatMain

@export var num_waves=0
signal combat_over
var waves=[]
var wave=-1
var check_combat_over=true

func _ready():
	super._ready()
	for i in range(0,num_waves):
		var node=find_child("Wave"+str(i+1))
		if node is Wave:
			waves.append(node)

func num_enemies_in_wave(w=wave, active=false):
	var res=0
	var node=self
	if w>=0 and w<num_waves:
		node=waves[w]
	for child in node.get_children():
		if child is Enemy and (!active or is_instance_valid(child.target)):
			res+=1
	return res

func num_enemies(active=false, all_waves=false):
	if all_waves:
		var res=0
		for w in range(0,len(waves)):
			res+=num_enemies_in_wave(w,active)
		return res
	return num_enemies_in_wave(wave,active)

func _process(_delta):
	if check_combat_over:
		check_combat_over=false
		if num_enemies(false,true)==0:
			combat_over.emit()
	if wave>=num_waves:
		return
	if wave<num_waves-1 and (num_enemies()==0 or (wave>=0 and num_enemies()==waves[wave].enemies_left_to_next_wave)):
		wave+=1
		waves[wave].enable()
	if wave==num_waves-1 and num_enemies()==0:
		wave+=1
		combat_over.emit()
