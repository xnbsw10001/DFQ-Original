extern float process;
extern float y;
extern float ratio;

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    vec4 retcolor = Texel(texture, textureCoords);
    retcolor = textureCoords.y - y < process * ratio ? retcolor * vec4(0.5, 0.5, 0.5, 1.0) : retcolor * color;

    return retcolor;
}