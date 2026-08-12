@tool 
class_name AfterImage2DFrame
extends Sprite2D


## A Single frame of the AfterImage2D Effect (Should be used by Plugin only!) 

## If this frame is allowed to be called to start fading 
var can_start : bool = true
var _after_image_parrent : AfterImage2D


func _process(delta: float) -> void:
	if(_after_image_parrent):
		if(not _after_image_parrent.frame_contiunity):
			update_sprite()

## Starts the fade visual & set can_start flag
func start_fade(time : float, final_offset : Vector2):
	if(can_start):
		can_start = false
		var tween : Tween = create_tween()
		tween.set_parallel()
		tween.tween_method(evaulate_alpha_curve, 0.0, 1.0, time)
		#tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, _after_image_parrent.ending_alpha), time)
		tween.tween_property(self, "position", position + final_offset, time)
		await tween.finished
		can_start = true


## Evaulates the alpha value of the curve from a tween_method call
func evaulate_alpha_curve(progress : float):
	if(_after_image_parrent.alpha_curve):
		var curve_value = _after_image_parrent.alpha_curve.sample(progress)
		self.modulate.a = lerp(0.0, 1.0, curve_value)
	else:
		## Default to liner fade from 1.0 to 0.0
		self.modulate.a = abs(1.0 - progress)


## Updates the image frame to match the bound sprite
func update_sprite():
	## Copy node data
	self.global_scale = _after_image_parrent.sprite_to_copy.global_scale
	self.global_rotation = _after_image_parrent.sprite_to_copy.global_rotation
	self.global_skew = _after_image_parrent.sprite_to_copy.global_skew
	
	## Sprite info
	self.texture = _after_image_parrent.sprite_to_copy.texture
	self.hframes = _after_image_parrent.sprite_to_copy.hframes
	self.vframes = _after_image_parrent.sprite_to_copy.vframes
	self.frame_coords = _after_image_parrent.sprite_to_copy.frame_coords
	self.frame = _after_image_parrent.sprite_to_copy.frame
	
	self.centered = _after_image_parrent.sprite_to_copy.centered
	self.offset = _after_image_parrent.sprite_to_copy.offset
	self.flip_h = _after_image_parrent.sprite_to_copy.flip_h
	self.flip_v = _after_image_parrent.sprite_to_copy.flip_v
	
	self.region_enabled = _after_image_parrent.sprite_to_copy.region_enabled
	self.region_rect = _after_image_parrent.sprite_to_copy.region_rect
	self.region_filter_clip_enabled = _after_image_parrent.sprite_to_copy.region_filter_clip_enabled
