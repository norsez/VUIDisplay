//POC: brightness + contrast as a last pass, three ways.
//
//Runs each of three approaches over the same source frame and writes PNGs to out/
//plus a metrics.csv comparing them. Read out/README_findings.md for the writeup.
//
//  A. CPU pixel loop on the target PImage          - any renderer, no new asset
//  B. fragment shader                              - needs P2D, needs data/poc_bc.frag
//  C. composite PGraphics: bloom baked in, then filter, then one blit
//
//This is a throwaway side project. It does not touch any tab of the VUIDisplay
//sketch. See PocBloom.pde for what was borrowed and why.

int W = 800;
int H = 640;

// output directory.
//
// savePath() is what the IDE's Save As / saveFrame() use, so it resolves to the
// sketch folder under the IDE and to the working directory otherwise. A plain
// "out/" string is taken literally by PImage.save() and saveBytes(), which silently
// wrote to the wrong place in a headless run.
//
// The sketch folder can also be overridden with the sketchbook.path system property,
// which is how a headless run pins it: -Dsketchbook.path=<abs path to sketch>
String OUT;

//(brightness, contrast) pairs to sweep. brightness is 0..255, contrast is a
//multiplier around mid grey where 1.0 is neutral.
float[][] SWEEP = {
  {0, 1.0},
  {40, 1.0},
  {0, 1.4}
};

// frames to process, as a name plus an explicit data/ path. loadImage(name) alone
// resolves against the sketch's data/ folder, which only works when the sketch is
// launched by the IDE. running it straight off a classpath needs the path spelled
// out, so both are given and the file-existence check picks.
String[][] FRAMES = {
  {"frame_native_800x640", "data/frame_native_800x640.png"},
  {"frame_composite",      "data/frame_composite.png"}
};

String METRICS;

PocBloom bloom;
PShader bcShader;

int frameCount = 0;
StringBuilder csv;

// size() lives in settings(), not setup(). Processing 4 requires this when the
// sketch runs outside the PDE - the IDE normally injects the equivalent. Works
// in the IDE too, so the POC runs both ways.
void settings() {
  size(W, H);
}

void setup() {
  // Output goes next to this tab, always.
  //
  // savePath("out") resolves against the sketchbook in Processing, which put these
  // files in /Applications/out - outside the repo entirely. The sketch's own folder
  // is what is wanted, and the working directory is already that folder when the
  // IDE runs the sketch.
  OUT = new java.io.File(".").getAbsolutePath() + "/out/";
  METRICS = OUT + "metrics.csv";

  bloom = new PocBloom();

  // Method B. A fragment shader needs a live GL context, which a headless run does
  // not have - loadShader() itself prints
  //    "loadShader(), or this particular variation of it, is not available with
  //     this renderer."
  // and hands back a PShader whose program never compiled. The result is not an
  // exception but silently wrong pixels, so availability is decided by actually
  // rendering a known pixel through the shader and reading it back.
  //
  // PROBE_B is set once the probe below succeeds.
  bcShader = null;
  boolean shaderUsable = false;

  try {
    bcShader = loadShader("poc_bc.frag");
    shaderUsable = probeShader();
  } catch (Exception e) {
    println("[poc] SHADER LOAD FAILED: " + e);
    bcShader = null;
  }

  if (shaderUsable) {
    println("[poc] method B AVAILABLE");
  } else {
    println("[poc] method B UNAVAILABLE - no GL context. "
            + "Run this sketch from the Processing IDE to exercise the shader.");
    bcShader = null;
  }

  // the output directory has to exist before save() runs
  java.io.File outDir = new java.io.File(OUT);
  if (!outDir.isDirectory()) {
    outDir.mkdirs();
  }

  println("[poc] output -> " + outDir.getAbsolutePath());

  csv = new StringBuilder();
  csv.append("frame,method,brightness,contrast,mean_delta_vs_A,max_delta_vs_A,pct_pixels_differ\n");

  for (int f = 0; f < FRAMES.length; f++) {
    runFrame(FRAMES[f][0], FRAMES[f][1]);
  }

  writeMetrics();
  println("[poc] done");
  exit();
}

void draw() {
  //setup() does all the work and calls exit(). draw() only exists because a
  //Processing sketch needs one to be a sketch at all.
  background(0);
}

//runs one source frame through all three methods and saves the results
void runFrame(String frameName, String path) {
  PImage src = loadImage(path);

  if (src == null) {
    println("[poc] SKIP " + frameName + " - could not load " + path);
    return;
  }

  //everything below works at the source's own size, not the window size, so the
  //composite frame does not get squashed into 800x640.
  int w = src.width;
  int h = src.height;

  println("[poc] " + frameName + " " + w + "x" + h);

  //baseline: the frame as it comes in, no bloom, no filter
  PImage baseline = src.copy();
  baseline.save(OUT + frameName + "_0_baseline.png");

  //bloom only. each sweep point gets its own copy so the three methods start
  //from the identical pixels.
  for (int s = 0; s < SWEEP.length; s++) {
    float b = SWEEP[s][0];
    float c = SWEEP[s][1];

    //src + bloom, on a buffer. all three methods start from identical pixels.
    PGraphics composited = srcWithBloom(src);
    if (s == 0) {
      composited.get().save(OUT + frameName + "_1_bloom_only.png");
    }

    //method A: CPU pixel loop straight onto the composited buffer
    PGraphics aBuf = createGraphics(src.width, src.height);
    aBuf.beginDraw();
    aBuf.image(composited, 0, 0);
    aBuf.endDraw();
    PocFilter.cpuPass(aBuf, b, c);
    PImage a = aBuf.get();
    aBuf.dispose();
    a.save(OUT + frameName + "_2A_cpu_b" + int(b) + "_c" + nf(c, 0, 2) + ".png");

    //method B: shader, only if a GL context exists
    PImage bb = null;
    if (bcShader != null) {
      bb = shaderApply(composited, b, c);
      bb.save(OUT + frameName + "_2B_shader_b" + int(b) + "_c" + nf(c, 0, 2) + ".png");
      recordDelta(frameName, "B_shader", b, c, a, bb);
    } else {
      println("[poc] method B skipped, no GL context");
    }

    //method C: composite buffer, filter it, then present it
    PImage cc = compositeThenFilter(srcWithBloom(src), b, c);
    cc.save(OUT + frameName + "_2C_composite_b" + int(b) + "_c" + nf(c, 0, 2) + ".png");

    recordDelta(frameName, "C_composite", b, c, a, cc);

    //method A is the reference the others are measured against, so record it too
    recordDelta(frameName, "A_cpu", b, c, a, a);
  }

  frameCount++;
}

// Renders a known mid-grey through the shader and checks the pixel came back
  // changed. A shader with no GL context fails silently, so its output is verified
  // rather than trusted.
  //
  // Brightness +60 on a 128 grey must land at 188. Anything else means the program
  // did not run.
  boolean probeShader() {
    PImage probe = createImage(4, 4, RGB);
    probe.loadPixels();
    for (int i = 0; i < probe.pixels.length; i++) {
      probe.pixels[i] = 0xff808080;
    }
    probe.updatePixels();

    PGraphics t = createGraphics(4, 4, P2D);
    t.beginDraw();
    t.background(0);
    t.shader(bcShader);
    PocFilter.shaderPass(probe, bcShader, 60, 1.0);
    t.noStroke();
    t.rectMode(CENTER);
    t.rect(2, 2, 4, 4);
    t.resetShader();
    t.endDraw();

    PImage got = t.get();
    t.dispose();

    int v = got.pixels[got.pixels.length / 2] & 0xff;
    println("[poc] shader probe: 128 +60 -> " + v);

    // +/-3 covers 8-bit rounding and the 0..1 uniform conversion
    return abs(v - 188) <= 3;
  }

//draws src into a fresh buffer and adds the bloom on top. this is the common
//starting point for all three methods, so they are compared on identical pixels.
PGraphics srcWithBloom(PImage src) {
  PGraphics buf = createGraphics(src.width, src.height);

  buf.beginDraw();
  buf.background(0);
  buf.image(src, 0, 0);
  buf.endDraw();

  // addTo() runs its own beginDraw()/endDraw() pair
  bloom.addTo(src, buf);

  return buf;
}

//method C: the composite buffer is filtered as a unit and then blitted once.
//the difference from A is structural, not arithmetic - A filters the buffer in
//place and reads it back, C filters it and presents it. the pixels are identical,
//which is the point worth recording: C costs one extra buffer and buys a clean
//place to hang further post effects.
PImage compositeThenFilter(PGraphics composited, float b, float c) {
  PocFilter.cpuPass(composited, b, c);

  PImage outImg = composited.get();
  composited.dispose();
  return outImg;
}

//method B: run the composited frame through the shader into an offscreen P2D
//target, so the main canvas is never involved.
PImage shaderApply(PGraphics composited, float b, float c) {
  PImage src = composited.get();

  PGraphics target = createGraphics(src.width, src.height, P2D);

  target.beginDraw();
  target.background(0);
  target.shader(bcShader);
  PocFilter.shaderPass(src, bcShader, b, c);
  target.noStroke();
  //the quad the shader is applied to. vTexCoord comes from the default aTexCoord
  //attribute, so a plain rect samples the texture across 0..1.
  target.rectMode(CENTER);
  target.rect(src.width / 2.0, src.height / 2.0, src.width, src.height);
  target.resetShader();
  target.endDraw();

  PImage outImg = target.get();
  target.dispose();
  return outImg;
}

//compares an image against method A's result for the same sweep point and
//appends a row to the csv
void recordDelta(String frame, String method, float b, float c, PImage ref, PImage test) {
  if (ref == test) {
    //A compared against itself. still record it so every row exists.
    csv.append(frame + "," + method + "," + int(b) + "," + nf(c, 0, 2)
               + ",0,0,0.000\n");
    return;
  }

  ref.loadPixels();
  test.loadPixels();

  int n = min(ref.pixels.length, test.pixels.length);
  long sum = 0;
  int maxd = 0;
  int differ = 0;

  for (int i = 0; i < n; i++) {
    int p = ref.pixels[i];
    int q = test.pixels[i];

    int dr = abs(((p & 0xff0000) >> 16) - ((q & 0xff0000) >> 16));
    int dg = abs(((p & 0x00ff00) >> 8) - ((q & 0x00ff00) >> 8));
    int db = abs((p & 0x0000ff) - (q & 0x0000ff));

    int d = max(dr, max(dg, db));
    sum += d;
    if (d > maxd) maxd = d;
    if (d > 0) differ++;
  }

  csv.append(frame + "," + method + "," + int(b) + "," + nf(c, 0, 2) + ","
             + nf((float)(sum) / n, 0, 4) + "," + maxd + ","
             + nf(100.0 * differ / n, 0, 4) + "\n");
}

void writeMetrics() {
  // save() has no (String, String) overload, so the csv goes out as bytes.
  // saveBytes() is the same path save() takes internally.
  saveBytes(METRICS, csv.toString().getBytes());
  println("[poc] wrote " + METRICS);
}