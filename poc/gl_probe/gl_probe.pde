// GL probe. Answers one question: can this machine give a Processing 4 sketch a
// live OpenGL context under the conditions the POC runs in?
//
// Separate from the POC on purpose - this is the gate that decides whether method
// B (fragment shader) is testable at all, and it should not be entangled with the
// filter comparisons.
//
// Reports and exits. Writes nothing.

int W = 256;
int H = 256;

PShader sh;

void settings() {
  size(W, H, P2D);
}

void setup() {
  println("[gl] renderer = P2D (requested)");

  if (g instanceof PGraphicsOpenGL) {
    println("[gl] main canvas IS PGraphicsOpenGL");
  } else {
    println("[gl] main canvas is NOT OpenGL: "
            + (g == null ? "null" : g.getClass().getName()));
  }

  // 1. can a shader even be constructed?
  sh = null;
  try {
    sh = loadShader("gl_probe.frag");
    println("[gl] loadShader returned: " + (sh == null ? "null" : "ok"));
  } catch (Exception e) {
    println("[gl] loadShader THREW: " + e);
  }

  if (sh == null) {
    finish("no PShader");
    return;
  }

  // 2. does it actually run? loadShader succeeding proves nothing.
  PImage probe = createImage(4, 4, RGB);
  probe.loadPixels();
  for (int i = 0; i < probe.pixels.length; i++) {
    probe.pixels[i] = 0xff808080;
  }
  probe.updatePixels();

  PGraphics t = createGraphics(4, 4, P2D);
  println("[gl] createGraphics(4,4,P2D) ok");

  t.beginDraw();
  t.background(0);
  t.shader(sh);
  sh.set("uTex", probe);
  sh.set("uBrightness", 60 / 255.0);
  sh.set("uContrast", 1.0);
  t.noStroke();
  t.rectMode(CENTER);
  t.rect(2, 2, 4, 4);
  t.resetShader();
  t.endDraw();

  PImage got = t.get();
  t.dispose();

  int v = got.pixels[got.pixels.length / 2] & 0xff;
  println("[gl] probe: 128 +60 -> " + v + " (expected ~188)");

  if (abs(v - 188) <= 3) {
    finish("GL WORKS");
  } else {
    finish("GL PRESENT BUT SHADER INERT (got " + v + ")");
  }
}

void finish(String verdict) {
  println("[gl] VERDICT: " + verdict);
  exit();
}

void draw() {
  background(0);
}