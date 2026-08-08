extends Camera3D
@onready var player: CharacterBody2D = $"../../../../Player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation.y = player.position.x/-500
	rotation.x = player.position.y/-500
