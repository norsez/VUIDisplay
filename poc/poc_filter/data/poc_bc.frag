//brightness / contrast as a fragment shader, for POC method B.
//
//   out = (in - 0.5) * contrast + 0.5 + brightness
//
//brightness is in normalised 0..1 units so the caller can pass the same
//0..255 numbers the CPU method uses, divided by 255.
//contrast is a multiplier around mid grey, matching the CPU method's pivot.

#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D uTex;
uniform float uBrightness;
uniform float uContrast;

varying vec4 vTexCoord;

void main() {
  vec4 c = texture2D(uTex, vTexCoord.rgb);

  vec3 rgb = (c.rgb - 0.5) * uContrast + 0.5 + uBrightness;

  gl_FragColor = vec4(clamp(rgb, 0.0, 1.0), c.a);
}