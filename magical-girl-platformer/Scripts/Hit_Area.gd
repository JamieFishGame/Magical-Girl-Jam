class_name HitArea extends Area2D

@export var damage := 5
var disableTimer = 0
var disabled = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if disableTimer > 0:
		disableTimer -= delta
		disabled = true
		for shape in get_children():
			shape.disabled = true
	elif disabled:
		disabled = false
		for shape in get_children():
			shape.disabled = false
