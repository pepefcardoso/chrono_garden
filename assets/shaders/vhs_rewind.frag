// vhs_rewind.frag — Chrono Garden VHS temporal distortion
// Vendian Chronos palette:
//   tertiary cyan  : vec3(0.000, 0.898, 1.000)  // #00E5FF
//   sepia warm     : vec3(1.000, 0.898, 0.714)  // old-photo warm
//   sepia shadow   : vec3(0.471, 0.310, 0.157)  // #795548 secondary

#include <flutter/runtime_effect.glsl>

// ── Uniforms (order MUST match Dart setFloat calls) ──────────────────────────
uniform float uTime;        // seconds since rewind started  (0..1 = active)
uniform float uIntensity;   // master strength driver        (0.0 = off, 1.0 = peak)
uniform vec2  uResolution;  // logical pixel dimensions of the overlay widget

// ── Sampler (after all float uniforms) ───────────────────────────────────────
uniform sampler2D uSceneTexture;  // rendered game board snapshot

out vec4 fragColor;

// ── Helpers ──────────────────────────────────────────────────────────────────

// Pseudo-random hash (Impeller-safe: no bitwise ops)
float hash(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}

// Scanline mask — horizontal bands simulating CRT/VHS raster
float scanline(float y, float lineCount, float strength) {
    float band = fract(y * lineCount);
    return 1.0 - strength * smoothstep(0.45, 0.55, band);
}

// Chromatic aberration — shifts R and B channels horizontally
vec3 chromaticAberration(sampler2D tex, vec2 uv, float amount) {
    vec2 shift = vec2(amount, 0.0);
    float r = texture(tex, uv + shift).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv - shift).b;
    return vec3(r, g, b);
}

// RGB → luminance (BT.601)
float luma(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

// Sepia toning using Chrono Garden secondary palette
vec3 sepia(vec3 c) {
    float l = luma(c);
    // Warm sepia blend
    vec3 warm  = vec3(1.000, 0.898, 0.714);
    vec3 shadow = vec3(0.471, 0.310, 0.157); // AppColors.secondary
    return mix(shadow, warm, l);
}

// Vertical hold jitter — shifts rows by a tiny horizontal offset
float jitter(float y, float time, float strength) {
    float band = floor(y * 12.0);
    float noise = hash(vec2(band, floor(time * 20.0)));
    return (noise - 0.5) * strength;
}

// ── Main ─────────────────────────────────────────────────────────────────────
void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uResolution;

    // Mirror Y: Flutter's coordinate origin is top-left
    vec2 texUV = vec2(uv.x, 1.0 - uv.y);

    // ── 1. Horizontal jitter (VHS tracking error) ─────────────────────────
    float jitterAmount = uIntensity * 0.006;
    texUV.x += jitter(texUV.y, uTime, jitterAmount);
    texUV = clamp(texUV, 0.0, 1.0);

    // ── 2. Chromatic aberration ───────────────────────────────────────────
    float aberration = uIntensity * 0.008;
    vec3 sceneColor = chromaticAberration(uSceneTexture, texUV, aberration);

    // ── 3. Film grain ──────────────────────────────────────────────────────
    float grain = hash(fragCoord + vec2(uTime * 100.0, 0.0));
    float grainStrength = uIntensity * 0.07;
    sceneColor += (grain - 0.5) * grainStrength;

    // ── 4. Scanlines ──────────────────────────────────────────────────────
    float scanStrength = uIntensity * 0.25;
    sceneColor *= scanline(uv.y, 200.0, scanStrength);

    // ── 5. Sepia blend ─────────────────────────────────────────────────────
    vec3 sepiaColor = sepia(sceneColor);
    float sepiaBlend = uIntensity * 0.75;
    sceneColor = mix(sceneColor, sepiaColor, sepiaBlend);

    // ── 6. Temporal cyan edge vignette (Vendian Chronos tertiary) ─────────
    //    A soft glow on screen edges when rewinding — uses #00E5FF
    vec2 centeredUV = uv * 2.0 - 1.0;
    float edgeDist = 1.0 - dot(centeredUV, centeredUV) * 0.5;
    edgeDist = clamp(edgeDist, 0.0, 1.0);
    vec3 cyanEdge = vec3(0.000, 0.898, 1.000); // AppColors.tertiary
    float edgeGlow = uIntensity * (1.0 - edgeDist) * 0.3;
    sceneColor = mix(sceneColor, cyanEdge, edgeGlow);

    // ── 7. Overall brightness dip (VHS tape "thud") ───────────────────────
    float brightness = 1.0 - uIntensity * 0.12;
    sceneColor *= brightness;

    fragColor = vec4(clamp(sceneColor, 0.0, 1.0), 1.0);
}