extends Attack
class_name ChargedAttack

@export var chargetime=1.0
signal fully_charged
var released
var charge=0.0
var charging=false
var charged=false

func reset_charge():
	charge=0.0
	charging=false
	if charged:
		charged=false
		damage/=2
		push/=1.5

func start_attack():
	super.start_attack()
	reset_charge()
	charging=true

func release():
	charging=false
	charge=0.0
	released=true
	look_target()
	if delay.is_stopped():
		attack()

func attack():
	if released:
		enable_hitbox()
		released=false
		attacking=true
		done_attacking=false
		can_attack=false
		if finished_time!=0:
			can_move=false
		readying=false
		attack_timer.start()

func disable_hitbox():
	super.disable_hitbox()
	reset_charge()

func enable_attack():
	super.enable_attack()
	reset_charge()
		
func _process(delta):
	super._process(delta)
	if charging:
		charge+=delta
	if charge>chargetime:
		fully_charged.emit()
		charge=0.0
		damage*=2
		push*=1.5
		charged=true
		charging=false
