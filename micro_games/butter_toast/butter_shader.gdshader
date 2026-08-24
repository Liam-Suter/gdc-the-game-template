shader_type canvas_item;

uniform sampler2D mask_texture;
uniform sampler2D base_texture;
uniform sampler2D masked_texture;

void fragment() {
    vec4 mask = texture(mask_texture, UV);
	vec4 base = texture(base_texture, UV);
	vec4 alt = texture(masked_texture, UV);

    // White mask → visible
    // Black mask → transparent
	COLOR = mix(base, alt, mask.r);
    //COLOR = vec4(1.0, 1.0, 1.0, mask.r + 0.1);
}