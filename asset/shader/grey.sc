extern bool enable = false;

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    vec4 retcolor = Texel(texture, textureCoords);
    
    if (enable) {
        retcolor.rgb = vec3(dot(retcolor.rgb, vec3(0.2126, 0.7152, 0.0722)));
    }

    return retcolor;
}