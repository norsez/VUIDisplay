// GL probe shader. Mirrors data/poc_bc.frag exactly, so a pass here means the same
// code path works.
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