shader_type canvas_item;

uniform vec3 base_color : source_color;

float swirl(vec2 uv, float size, int arms)
{
	float angle = -atan(-uv.y + 0.5, uv.x - 0.5) + TIME * -2.0;
	float len = length(uv - vec2(0.5, 0.5));

	return sin(len * size + angle * float(arms));
}

void fragment()
{
	float swirl = swirl(UV, 60.0, 6);
	COLOR += vec4(base_color * swirl, 1.0);
}
