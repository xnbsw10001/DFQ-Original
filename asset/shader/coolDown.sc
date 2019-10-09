const float ninety = 1.5707964;
extern float radian;
extern vec2 center;

vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
    if (radian == 0.0) {
        return vec4(0.0);
    }

    float r = abs(atan((center.y - textureCoords.y) / (center.x - textureCoords.x)));

    if (textureCoords.x >= center.x) {
        if (textureCoords.y < center.y) {
            r = ninety - r;
        }
        else {
            r += ninety;
        }
    }
    else {
        if (textureCoords.y < center.y) {
            r += ninety * 3.0;
        }
        else {
            r = ninety - r;
            r += ninety * 2.0;
        }
    }

    return r >= radian ? Texel(texture, textureCoords) * color : vec4(0.0);
}