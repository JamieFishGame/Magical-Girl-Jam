shader_type canvas_item;
//uniform sampler2D pattern: repeat_enable, filter_nearest, source_color;


uniform sampler2D tex: repeat_enable, filter_nearest, source_color;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(tex,UV);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
