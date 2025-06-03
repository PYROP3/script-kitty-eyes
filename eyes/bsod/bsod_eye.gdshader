shader_type canvas_item;

uniform vec3 base_color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = vec4(base_color * vec3(1.-step(.9, COLOR.b)) + vec3(step(.9, COLOR.b)), 1.);
	//COLOR = COLOR * vec4(0., 1., 1., 1.);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
