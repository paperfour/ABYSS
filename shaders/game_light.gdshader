shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform int amount = 100;

void fragment()
{

	float rounded_uv_x = float(floor(SCREEN_UV.x * float(amount))) / float(amount);
	float rounded_uv_y = float(floor(SCREEN_UV.y * float(amount))) / float(amount);

	rounded_uv_x = float(floor(SCREEN_UV.x * 100.0)) / 100.0;
	rounded_uv_y = float(floor(SCREEN_UV.y * 100.0)) / 100.0;




	vec4 text = texture(SCREEN_TEXTURE, vec2(rounded_uv_x, rounded_uv_y));

	COLOR = text;
}

void light() {
}
