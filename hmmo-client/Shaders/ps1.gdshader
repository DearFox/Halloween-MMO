shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D mask_texture : repeat_disable, filter_nearest;
uniform float resolution_scale : hint_range(0.1, 1.0, 0.01) = 0.25;
uniform int color_levels : hint_range(2, 32) = 8;
uniform float dither_strength : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform bool enable_dither = true;

const mat4 bayer_matrix = mat4(
    vec4(0.0, 8.0, 2.0, 10.0),
    vec4(12.0, 4.0, 14.0, 6.0),
    vec4(3.0, 11.0, 1.0, 9.0),
    vec4(15.0, 7.0, 13.0, 5.0)
);

void fragment() {
    vec2 uv = UV;

    // имитация низкого разрешения с учётом фактического размера экрана
    vec2 screen_resolution = max(vec2(1.0), vec2(1.0) / SCREEN_PIXEL_SIZE);
    vec2 target_resolution = max(vec2(1.0), screen_resolution * resolution_scale);
    vec2 pixelated_uv = floor(uv * target_resolution) / target_resolution;

    // выборка из viewport текстуры
    vec4 pixelated_col = texture(screen_texture, pixelated_uv);

    // квантование цвета
    pixelated_col.rgb = floor(pixelated_col.rgb * float(color_levels)) / float(color_levels);

    // дизеринг
    if (enable_dither) {
        ivec2 pos = ivec2(mod(FRAGCOORD.xy, 4.0));
        float threshold = bayer_matrix[pos.y][pos.x] / 16.0;
        pixelated_col.rgb += (threshold - 0.5) * (1.0 / float(color_levels)) * dither_strength;
    }

    // наложение маски поверх результата
    vec4 mask_color = texture(mask_texture, uv);
    COLOR.rgb = mix(pixelated_col.rgb, mask_color.rgb, mask_color.a);
    COLOR.a = pixelated_col.a;
}
