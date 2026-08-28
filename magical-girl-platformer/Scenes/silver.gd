class_name silver extends Area2D

var amount = 1
var speed = 0
@onready var player = Glob.playerRef
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = randf_range(0,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed += delta
	position = position.lerp(player.position,speed*delta)
