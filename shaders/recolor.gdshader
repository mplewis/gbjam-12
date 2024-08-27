shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float threshold0 = 0.0;
uniform float threshold1 : hint_range(0.0, 1.0) = 0.25;
uniform float threshold2 : hint_range(0.0, 1.0) = 0.5;
uniform float threshold3 : hint_range(0.0, 1.0) = 0.75;
uniform float threshold4 = 1.0;

uniform vec4 color1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.333, 0.333, 0.333, 1.0);
uniform vec4 color3 : source_color = vec4(0.667, 0.667, 0.667, 1.0);
uniform vec4 color4 : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = (bg.r + bg.g + bg.b) / 3.0;
	bool x_odd = int(SCREEN_UV.x * 160.0) % 2 == 0;
	bool y_odd = int(SCREEN_UV.y * 224.0) % 2 == 0;
	bool odd = x_odd != y_odd;

	float threshold1_5 = threshold1 + (threshold2 - threshold1) / 2.0;
	float threshold2_5 = threshold2 + (threshold3 - threshold2) / 2.0;
	float threshold3_5 = threshold3 + (1.0 - threshold3) / 2.0;

	if (avg < threshold1) {
		COLOR = color1;
	} else if (avg < threshold1_5) {
		if (odd) {
			COLOR = color1;
		} else {
			COLOR = color2;
		}
	} else if (avg < threshold2) {
		COLOR = color2;
	} else if (avg < threshold2_5) {
		if (odd) {
			COLOR = color2;
		} else {
			COLOR = color3;
		}
	} else if (avg < threshold3) {
		COLOR = color3;
	} else if (avg < threshold3_5) {
		if (odd) {
			COLOR = color3;
		} else {
			COLOR = color4;
		}
	} else {
		COLOR = color4;
	}

}
