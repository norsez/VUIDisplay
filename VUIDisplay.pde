import controlP5.*;
import com.hamoid.*;  //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import java.awt.event.KeyEvent;
boolean DEBUG = false; //<>// //<>//
boolean APPLY_BLOOM = true;
boolean cp5Hidden = true;
boolean RECORD_VIDEO = false;
float RECORD_SECS = 60 * 3.35;
float framesToRecord;
color C_DEFAULT_FILL = color(151,216,204);


long APP_FRAME_RATE = 24;
long APP_PARAM_UPDATE_RATE = (long)(APP_FRAME_RATE * 0.25);

BloomPProcess bloom = new BloomPProcess();
PFont FONT_6, FONT_8, FONT_16;
PGraphics g;
List<DisplayInterface> displays;
AbstractLayout layout;

float controlA = 0, controlB = 0, controlC = 0, controlD = 0;
final int MIN_CONTROL = 0, MAX_CONTROL = 128;
boolean paused = false;
int wheelMode = KeyEvent.VK_A;


VideoExport videoExport;
ControlP5 cp5;

void initDisplays() {
  ARect bound = windowBoundingBox();
  displays = new ArrayList();


  String [] imageFilenames = new String [14];
  for(int i=0; i < imageFilenames.length; i++) {
    imageFilenames[i] = "chang" + (i+1) + ".jpg";
  }
  ARect picBound = new ARect(0, bound.height * 0.5, 480, 320);
  DisplayLaserPaint disPic = new DisplayLaserPaint(picBound, imageFilenames);
  displays.add(disPic);
  displays.add(new DisplayBarWaveForm(bound));
  displays.add(new DisplayBetaBall(bound));
  displays.add(new DisplayBouncingLaser(bound));
  displays.add(new DisplayWave(bound));
  displays.add(new DisplayFFTAlphaBall(bound));
  displays.add(new DisplayRunningWave(bound));
  displays.add(new DisplayWaveDNA(bound));
  displays.add(new DisplaySpectrumBars(bound));
  

  layout = new LayoutWithFixedDisplaySet(bound, displays);


  /// add display toggles into cp5
  for (int i=0; i<displays.size(); i++) {
    String num = String.format("%3s", "" + (i+1));
    cp5.addToggle("d" + num, true);
  }
}

void setup() {
  size(480, 640);
  
  cp5 = new ControlP5(this);
  cp5.hide();

  background(0);
  frameRate(APP_FRAME_RATE);
  FONT_6 = loadFont("automat-6.vlw");
  FONT_8 = loadFont("04b08-8.vlw");
  FONT_16 = loadFont("Arcade-16.vlw");
  logG = createGraphics(width, height);

  g = createGraphics(width, height);
  initTables();
  initColorMap(true);
  initAudioInput();
  initVideoExport();
  initDisplays();
}

void initVideoExport() {
  if (!RECORD_VIDEO) return;
  videoExport = new VideoExport(this, "export.mp4", g);
  videoExport.startMovie();
  framesToRecord = RECORD_SECS * frameRate;
}


void draw() {

  tickFFT();
  tickAmp();
  tickWave();


  if (!paused) {
    g.beginDraw();

    layout.draw(g);

    showLogList(g);
    g.endDraw();
  }

  image(g, 0, 0);
  if (APPLY_BLOOM) {
    bloom.ApplyBloom();
  }

  if (RECORD_VIDEO) {
    videoExport.saveFrame();
    if (frameCount >= framesToRecord) {
      videoExport.endMovie();
      exit();
    }
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
      d.toggleHidden();
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
  } else if (keyCode == KeyEvent.VK_X) {
    println("bang!");
    controlA = controlB = controlC = controlD = 0;
    layout.bang();
  } else if (keyCode == KeyEvent.VK_Q && RECORD_VIDEO) {
    videoExport.endMovie();
    exit();
  } else if (keyCode == KeyEvent.VK_W) {
    DEBUG = !DEBUG;
  } else if (keyCode == KeyEvent.VK_H) {
    this.cp5Hidden = !this.cp5Hidden;
    if (this.cp5Hidden) {
      cp5.hide();
    } else {
      cp5.show();
    }
  }

  println(controlA + " " + controlB + " " + controlC + " " + controlD); //<>//
} //<>//
 //<>// //<>// //<>//
public void controlEvent(ControlEvent e) { //<>// //<>// //<>// //<>// //<>//
  String ctrlName = e.getName(); //<>//
  println(ctrlName); //<>// //<>// //<>//
   //<>// //<>//
  if (ctrlName.startsWith("d")) { //<>// //<>// //<>//
    String ctrlId = ctrlName.substring(1, 4).trim(); //<>// //<>//
    println(ctrlId);
    int index = Integer.parseInt(ctrlId) - 1; //<>// //<>//
    displays.get(index).toggleHidden();
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (wheelMode == KeyEvent.VK_A) {
    controlA += e;
    controlA = (constrain(controlA, MIN_CONTROL, MAX_CONTROL));
  } else if (wheelMode == KeyEvent.VK_B) {
    controlB += e;
    controlB = (constrain(controlB, MIN_CONTROL, MAX_CONTROL));
  } else if (wheelMode == KeyEvent.VK_C) {
    controlC += e;
    controlC = (constrain(controlC, MIN_CONTROL, MAX_CONTROL));
  } else if (wheelMode == KeyEvent.VK_D) {
    controlD += e;
    controlD = (constrain(controlD, MIN_CONTROL, MAX_CONTROL));
  }

  println(controlA + " " + controlB + " " + controlC + " " + controlD);
}
