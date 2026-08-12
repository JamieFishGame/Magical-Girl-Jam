class_name DamageControl extends Area2D

const DamNumScene = preload("uid://d22brtrf8062c")
const DamParticles = preload("uid://c8dpe88mtbq33")

@export var health := 20
@export var deathSpeed = .5
@export var sprite: Sprite2D
@export var core: Node2D
@onready var healthbar: TextureProgressBar = $Healthbar
@onready var player = Glob.playerRef
var iSecs = 0
var iSecAmount = .3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthbar.max_value = health
	healthbar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if iSecs > 0:
		iSecs -= delta

func _on_hit_area_area_entered(area: Area2D) -> void:
	var hit_area := area as HitArea
	
	
	if hit_area != null and iSecs <= 0:
		TakeDamage(hit_area.damage,area)
		
		
func TakeDamage(damage,area: Area2D):
	
	iSecs = iSecAmount
	if sprite != null:
		var flashTween = create_tween()
		flashTween.tween_property(sprite,"modulate",Color.WHITE,iSecAmount).from(Color(3.168, 0.628, 3.168, 1.0))
	Glob.camRef.CamShake(damage*3,global_position)
	player.OnHitEnemy(area)
	health -= damage
	print("AHHHH    "+str(damage)+" Damage Taken")
	healthbar.value = health
	
	var DamNum: DamageNumber = DamNumScene.instantiate()
	DamNum.text = str(damage)
	DamNum.color = Color(2.885, 0.367, 2.929, 1.0)
	DamNum.duration = 5
	DamNum.global_position = global_position
	add_sibling(DamNum)
	DamNum.Activate()
	
	
	var particleInst: GPUParticles2D = DamParticles.instantiate()
	particleInst.amount = damage#*2
	particleInst.global_position = global_position
	particleInst.look_at(area.global_position)
	particleInst.rotate(PI)
	add_sibling(particleInst)
	particleInst.emitting = true
	
	if health <= 0:
		Die()
	
func Die():
	var fadeTween = create_tween()
	fadeTween.tween_property(core,"modulate",Color.TRANSPARENT,deathSpeed)
	await get_tree().create_timer(deathSpeed).timeout
	core.queue_free()
