#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};

layout(binding = 1) uniform sampler2D source;

void main(void) {
    vec4 sourceColor = texture(source, qt_TexCoord0);
    float alpha = 1.0;
    float x = qt_TexCoord0.x - 0.5;
    float y = qt_TexCoord0.y - 0.5;

    // Behind the bar, hide all items.
    if (abs(y) < 0.125 && x < 0.0)
        alpha = 0.0;

    // Soften the transition between the bar and above/below it.
    if (abs(y) > 0.125 && x < 0.0)
        alpha = abs(y) * 5.0;

    if (alpha > 1.0)
        alpha = 1.0;

    fragColor = sourceColor * alpha * qt_Opacity;
}
