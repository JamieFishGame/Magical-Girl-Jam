class_name DamageControl extends Area2D
signal damaged

@export var health := 20

var iSecs = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if %Player != null:
		var player = %Player
		connect("damaged",player.ForwardDash)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if iSecs > 0:
		iSecs -= delta

func _on_hit_area_area_entered(area: Area2D) -> void:
	var hit_area := area as HitArea
	if hit_area != null and iSecs <= 0:
		TakeDamage(hit_area.damage)
		
func TakeDamage(damage):
	health -= damage
	print("AHHHH    "+str(damage)+" Damage Taken")
	damaged.emit()
