shader_type canvas_item;


uniform vec3 monochrome_color : source_color = vec3(1.0, 1.0, 1.0);
uniform bool enable = false;


void fragment() {
	if(enable)
	{
		COLOR.rgb = monochrome_color; 
	}
	
}
