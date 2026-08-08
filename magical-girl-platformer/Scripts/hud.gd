extends CanvasLayer
@onready var attack_cooldown: TextureProgressBar = $"Attack Cooldown"

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		#print(attack_cooldown.value)
		if player.attackCooldown <= 0:
			attack_cooldown.max_value = 0
		
		if player.attackCooldown > attack_cooldown.max_value:
			attack_cooldown.max_value = player.attackCooldown
		
		attack_cooldown.value = attack_cooldown.max_value - player.attackCooldown
		
		
