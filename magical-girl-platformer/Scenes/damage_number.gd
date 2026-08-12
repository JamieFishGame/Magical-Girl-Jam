extends Label
class_name DamageNumber

var duration := 5
var color : Color
var velocity = 20
# Called when the node enters the scene tree for the first time.
func Activate() -> void:
	#global_position -= size/2.0
	if color:
		add_theme_color_override("font_color",color)
	var fadeout = create_tween()
	fadeout.tween_property(self,"self_modulate",Color(0.58, 0.0, 1.0, 0.0),duration)
	var speedup = create_tween()
	speedup.tween_property(self,"velocity",100,duration)
	await fadeout.finished
	queue_free()
	
func _process(delta: float) -> void:
	position.y -= velocity*delta
