class_name Hud extends CanvasLayer
@onready var attack_cooldown: TextureProgressBar = $"Attack Cooldown"
@onready var healthbar: TextureProgressBar = $Healthbar
@onready var vhs: ColorRect = $VHS
@onready var silver_count: RichTextLabel = $SilverCount

@export var player: Player
var vhsTimer = 0
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
		
		healthbar.size.x = 2*player.maxHealth
		healthbar.max_value = player.maxHealth
		healthbar.value = player.health
		if vhsTimer > 0:
			vhsTimer -= delta
			vhs.modulate.a = 1
		else:
			vhs.modulate.a = 0
		silver_count.text = str(player.silver)
