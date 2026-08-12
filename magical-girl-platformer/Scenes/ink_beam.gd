extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#points.append(Vector2.ZERO)
	var fadeTween = create_tween()
	fadeTween.tween_property(self,"modulate",Color.TRANSPARENT,3.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
