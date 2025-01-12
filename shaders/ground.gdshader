shader_type canvas_item;

uniform vec2 tile_size;
uniform vec2 highlight_pos;
uniform vec4 highlight_color;
uniform float highlight_intensity;
varying vec2 world_position;

void vertex() {
	// calculate the world position for use in the fragment shader
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // Check if the current fragment belongs to the highlighted tile
    vec2 tile_coord = floor(world_position / tile_size);
    if (tile_coord == highlight_pos) {
        vec4 original_color = texture(TEXTURE, UV);
        COLOR = mix(original_color, highlight_color, highlight_intensity);
    } else {
        COLOR = texture(TEXTURE, UV);
    }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
