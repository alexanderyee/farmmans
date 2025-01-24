shader_type canvas_item;

uniform float blue = 1.0;

void vertex() {
	//VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	//COLOR.a = sin(TIME*5.0) + 1.0;
	//COLOR.r = sin(TIME*5.0);

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
