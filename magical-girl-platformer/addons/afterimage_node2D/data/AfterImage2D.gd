@tool
## An object that spawns copies of a sprite and fades them out to produce a visual effect 
class_name AfterImage2D
extends Node2D


## Frame preload 
var image_frame_ref = preload("res://addons/afterimage_node2D/data/AfterImageFrame2D.tscn")

## Signals

## Called when a frame is spawned, passing that frame to be overided or modified 
signal frame_spawned(frame : Sprite2D)


## Members

@export_group("")
## If the effect should be turned on  
@export var emiting : bool = true
## The sprite to copy for the effect (Needs to be set for the effect to work!) 
@export var sprite_to_copy : Sprite2D 

## The Curve of the alpha values to follow over the lifetime of the fade
@export var alpha_curve : Curve


@export_group("Frame Properties")
## Should the effect fade at all? (Only disable if you are using the system for another purpose!) 
#@export var do_fade : bool = true

## If the effect should use the frame of the sprite when it was spawned or match what is displayed on the sprite
## (Note: setting this to false is more preformance intensive!) 
@export var frame_contiunity : bool = true

## How many frames are generated for the trail  
@export_range(0, 999999) var trail_amount : int = 3:
	set(value):
		trail_amount = value
		_update_trail_amount()
## How long should the fade be? 
@export_range(0, 999999) var fade_time : float = 0.5




### The starting Alpha modulate of the sprite frame when it is displayed 
#@export_range(0.0, 1.0) var starting_alpha : float = 1.0
### The ending Alpha modulate of the sprite frame when it is at the end of the Fade Time
#@export_range(0.0, 1.0) var ending_alpha : float = 0.0
## Sets the frames to be a monochrome sprite shader
## (Uses the Modulate Property for color) 
@export var monochrome_modulate : bool = true 
## if overide_frame_color is true, the color to make the frames apear 
#@export_color_no_alpha var frame_color_overide : Color = Color(1.0, 1.0, 1.0, 1.0)

@export_group("Frame Physics")
## A direction frames should move toward as they fade out, offseted by their current position 
@export var frame_final_pos_offset : Vector2 = Vector2(0, 0)





### Non-Editor Members

## The array of loaded trail frames : with [0] representing the most recently (or soon to be) emited index of the trail and the last element being the oldest
var trail_objects : Array[AfterImage2DFrame] = []

func _ready() -> void:
	_update_trail_amount()


#region Effect Population

## Updates the trail amount, called when trail_amount is changed 
func _update_trail_amount():
	if(trail_objects.size() < trail_amount):
		## Add objects from the trail starting at the backmost index
		for i in range(0, trail_amount - trail_objects.size()):
			var frame : AfterImage2DFrame = image_frame_ref.instantiate()
			frame._after_image_parrent = self
			trail_objects.append(frame)
			add_child(frame)
	elif(trail_objects.size() > trail_amount):
		## Remove objects from the trail starting at the backmost index
		for i in range(trail_objects.size() - 1, trail_amount - 1, -1):
			trail_objects[i].free()
			trail_objects.remove_at(i)

#endregion 


#region Visual Effect

var wait_finished = true

func _process(delta: float) -> void:
	
	if(emiting and wait_finished and trail_objects.size() > 0 and sprite_to_copy):
		## How long to wait is dependent on the frame count and fade time 
		var next_wait_invertal : float = fade_time / trail_amount
		
		## Select the first index of the array and copy data to it
		_copy_sprite_to_index(0)
		
		## Then tell that frame to play!
		trail_objects[0].start_fade(fade_time, frame_final_pos_offset)
		## After priming, send the index to the back of the array! 
		trail_objects.push_back(trail_objects.pop_front())
		
		## lastly, wait for the interal to pass
		wait_finished = false
		await get_tree().create_timer(next_wait_invertal).timeout
		wait_finished = true

## (INTERNAL HELPER) Copies the selected sprite's data to an index of the array (typicaly 0) 
func _copy_sprite_to_index(index : int):
	
	##Reparent to topmost child 
	move_child(trail_objects[0], get_child_count() - 1)
	
	## Set position to emmiter position to start
	trail_objects[0].position = global_position ## Postion of emmiter 
	
	## Set starting alpha modulate
	trail_objects[0].modulate = modulate
	if(alpha_curve):
		trail_objects[0].modulate.a = alpha_curve.sample(0.0) ## Get starting value of curve
	else:
		trail_objects[0].modulate.a = 1.0
	
	## Call update function
	trail_objects[0].update_sprite()
	
	## Emit Signal for frame spawn (Before shader) 
	frame_spawned.emit(trail_objects[0])
	
	## Set shadr parameters
	trail_objects[0].material.set_shader_parameter("enable", monochrome_modulate)
	trail_objects[0].material.set_shader_parameter("monochrome_color", modulate)




#endregion 


## Hides all frames of the AfterImage2D object instantly 
func hide_all_frames() -> void:
	pass
