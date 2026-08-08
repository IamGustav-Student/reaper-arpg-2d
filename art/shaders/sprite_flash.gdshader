shader_type canvas_item;

// Hit Flash Shader (GDD sección 2.2 / 8.1). Controlar desde código con:
// sprite.material.set_shader_parameter("flash_amount", 1.0)

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = vec4(mix(tex_color.rgb, flash_color.rgb, flash_amount), tex_color.a);
}
