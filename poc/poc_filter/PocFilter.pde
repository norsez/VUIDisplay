//brightness / contrast, two ways.
//
//  cpuPass()  - method A. a per-pixel loop over img.pixels. works on any renderer.
//  shaderPass() - method B. a fragment shader, needs a P2D/P3D renderer.
//
//Both take the same numbers: brightness in 0..255, contrast as a multiplier
//around mid grey (1.0 = no change). The formula is identical in both:
//
//   out = (in - pivot) * contrast + pivot + brightness
//
//pivot is 127.5 so the two halves of the range are weighted evenly.

class PocFilter
{
  //kept as a float so the half-step at the pivot is not lost to int truncation
  static final float PIVOT = 127.5;

  //method A: CPU pixel loop
  //
  //this is the pass that would go on the main canvas after bloom.ApplyBloom().
  //it touches the PImage's own pixel array, so it works on the main canvas and on
  //any PGraphics regardless of renderer.
  static void cpuPass(PImage img, float brightness, float contrast) {
    img.loadPixels();

    int[] px = img.pixels;
    int n = px.length;

    float pivot = PIVOT;
    float bright = brightness;
    float con = contrast;

    for (int i = 0; i < n; i++) {
      int c = px[i];

      int r = (c & 0xff0000) >> 16;
      int g = (c & 0x00ff00) >> 8;
      int b = c & 0x0000ff;

      int nr = (int)((r - pivot) * con + pivot + bright);
      int ng = (int)((g - pivot) * con + pivot + bright);
      int nb = (int)((b - pivot) * con + pivot + bright);

      //clamp rather than wrap. wrapping would turn a bright pixel into a dark one
      //and invert the whole image at high brightness.
      if (nr < 0) nr = 0; else if (nr > 255) nr = 255;
      if (ng < 0) ng = 0; else if (ng > 255) ng = 255;
      if (nb < 0) nb = 0; else if (nb > 255) nb = 255;

      px[i] = 0xff000000 | (nr << 16) | (ng << 8) | nb;
    }

    img.updatePixels();
  }

  //method B: fragment shader
  //
  //the shader reads a texture and writes a full-screen quad, so this needs a
  //P2D or P3D target. it returns the shader so the caller can inspect it, and it
  //leaves the shader applied - the caller resets with resetShader().
  static PShader shaderPass(PImage src, PShader sh, float brightness, float contrast) {
    // set(), not setUniform(). PShader.setUniform(String, ...) is protected in
    // Processing 4; set(String, ...) is the public entry point and takes the same
    // arguments.
    sh.set("uTex", src);
    //the shader works in 0..1, the caller works in 0..255
    sh.set("uBrightness", brightness / 255.0);
    sh.set("uContrast", contrast);
    return sh;
  }

  //method C needs no filter code of its own - it is the same cpuPass applied to a
  //composite buffer that already has the bloom baked in. see poc_filter.pde.
}