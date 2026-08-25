shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
uniform float intensity = 1;

void fragment() {
    vec4 mask = texture(mask_texture, UV);
	COLOR = vec4(color, pow(mask.r, 1.5) * intensity);
}