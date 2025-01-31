shader_type canvas_item;

uniform bool is_in_hitstop;
uniform float flash_intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    if (is_in_hitstop) {
		color.rgb *= flash_intensity; // Increase brightness
	}
    COLOR = color;
}