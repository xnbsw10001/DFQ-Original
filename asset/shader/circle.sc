extern vec2 center;
extern float length = 0.5;

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    float v = distance(textureCoords, center);
	return v > length ? vec4(0.0) : Texel(texture, textureCoords) * color;
}