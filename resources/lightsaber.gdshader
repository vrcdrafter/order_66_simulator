shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 color : source_color = vec4(1,0,0,1);
uniform float size : hint_range(1.0, 1.5, 0.01) = 1.05;
uniform float time;
void vertex() {
	float oscillating_value = (sin(TIME * 15.0) + 1.1) * .1;
	VERTEX.x *= oscillating_value + 1.8;
	VERTEX.z *= oscillating_value + 1.8;

}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
