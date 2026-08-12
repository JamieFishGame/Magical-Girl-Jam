class_name mainCamera extends Camera2D

var shakeStrength := 0.0
var shakeTimer = 0
var shakeSpeed = Vector2(30,30)
var shakeVec = Vector2.DOWN

func _process(delta: float) -> void:
	shakeTimer += delta
	if shakeStrength > 0:
		offset = shakeVec*shakeStrength*sin(shakeSpeed.x*shakeTimer)
	else:
		offset = Vector2.ZERO

func CamShake(intensity := 10.0, origin := global_position - Vector2(0,1),normal := Vector2.ZERO):
	if normal != Vector2.ZERO:
		shakeVec = normal
	else:
		shakeVec = global_position.direction_to(origin)
	shakeTimer = 0
	shakeStrength = intensity
	var shakeTween = create_tween()
	shakeTween.tween_property(self,"shakeStrength",0,.3)
