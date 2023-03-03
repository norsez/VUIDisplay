 //<>//
import java.awt.event.KeyEvent;

boolean APPLY_BLOOM = true;
BloomPProcess bloom = new BloomPProcess();

PGraphics g;
List<DisplayInterface> displays;
AbstractLayout layout;

float controlA, controlB, controlC, controlD = 0;
boolean paused = false;
int wheelMode = KeyEvent.VK_A;

void initDisplays() {
  ARect bound = windowBoundingBox();
  displays = new ArrayList();

  displays.add(new DisplayStarZoom(bound));
  displays.add(new DisplayBarWaveForm(bound));
  displays.add(new DisplayBetaBall(bound));
  displays.add(new DisplayBouncingLaser(bound));
  displays.add(new DisplayWave(bound));
  displays.add(new DisplayRunningWave(bound));
  displays.add(new DisplayFFTPulse(bound));
  displays.add(new DisplayFFT(bound));
  displays.add(new DisplayWaveDNA(bound));
  displays.add(new DisplaySpectrumBars(bound));
  displays.add(new DisplaySourceCode(bound));

  layout = new LayoutAllInOne(bound, displays);
}

void setup() {
  size(640, 240);
  background(0);
  frameRate(24);

  g = createGraphics(width, height);

  initColorMap(true);
  initDisplays();
  initAudioInput();
}

void draw() {

  tickFFT();
  tickAmp();
  tickWave();


  if (!paused) {
    g.beginDraw();
    g.background(0, 25);
    //g.blendMode(SCREEN);
    layout.draw(g);
    

    g.endDraw();
  }

  image(g, 0, 0);
  if (APPLY_BLOOM) {
    bloom.ApplyBloom();
  }
}

int [] displayKey = {KeyEvent.VK_1, KeyEvent.VK_2, KeyEvent.VK_3, KeyEvent.VK_4, KeyEvent.VK_5
  , KeyEvent.VK_6, KeyEvent.VK_7, KeyEvent.VK_8, KeyEvent.VK_9, KeyEvent.VK_0};


void keyPressed() {
  println(keyCode);

  if (keyCode >= KeyEvent.VK_1 && keyCode <= KeyEvent.VK_9) {
    int k = keyCode - KeyEvent.VK_1;
    if (k < displays.size()) {
      DisplayInterface d = displays.get(k);
      d.toggleHidden(); //<>//
    }
  } else if (keyCode == KeyEvent.VK_A
    || keyCode == KeyEvent.VK_B
    || keyCode == KeyEvent.VK_C
    || keyCode == KeyEvent.VK_D) {

    wheelMode = keyCode;
  } else if (keyCode == KeyEvent.VK_SPACE) {
    paused = !paused;
  } else if (keyCode == KeyEvent.VK_Z) {
    this.layout.toggleAuto();
  }

  println(controlA + " " + controlB + " " + controlC + " " + controlD);
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (wheelMode == KeyEvent.VK_A) {
    controlA += e;
  } else if (wheelMode == KeyEvent.VK_B) {
    controlB += e;
  } else if (wheelMode == KeyEvent.VK_C) {
    controlC += e;
  } else if (wheelMode == KeyEvent.VK_D) {
    controlD += e;
  }

  println(controlA + " " + controlB + " " + controlC + " " + controlD);
}
