vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    vec4 texcolor = Texel(texture, textureCoords);
    color.a *= texcolor.a;

    return color;
}