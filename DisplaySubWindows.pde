//<>// //<>// //<>// //<>// //<>// //<>// //<>//
class Subwindow extends Movable {

  ARect bound;

  void setImage(PImage img) {
    PGraphics buf = createGraphics(img.width, img.height);
    buf.beginDraw();
    buf.image(img, 0, 0);
    buf.noFill();
    buf.stroke(C_DEFAULT_FILL, 200);
    buf.strokeWeight(1);
    buf.rect(0, 0, img.width - 1, img.height - 1, 4);
    buf.textFont(FONT_6);
    String txt = randomString(5);
    buf.text(txt, img.width - textWidth(txt), img.height - 8);
    buf.endDraw();
    super.gToMove = buf;
  }
}


class DisplaySubWindows extends AbstractDisplay implements StateActionCallback {
  List<Subwindow> subwindows;
  int MAX_SUB_WINS = 3;

  float currentFrame_saveFrame, dxFrame_saveFrame;
  String SAVED_FRAME_NAME = "DisplaySubWindows.png";
  int save_frame_count = 0;

  PGraphics localG;
  int state = 0;
  int STATE_WAIT=0, STATE_LAYOUT = 1, STATE_HOLD = 2, STATE_DISMISS = 3;

  ObjectMover pmover = new ObjectMover();
  StateSequenceController scon = new StateSequenceController();

  DisplaySubWindows(ARect bound) {
    super(bound);
    subwindows = new ArrayList();

    pmover = new ObjectMover();

    for (int i=0; i< MAX_SUB_WINS; i++) {
      Subwindow sw = new Subwindow();
      this.subwindows.add(sw);
      pmover.movables.add(sw);
    }


    scon = new StateSequenceController();
    scon.listeners.add(this);
    scon.addId(this, STATE_WAIT, 2.1 * frameRate);
    scon.addId(this, STATE_LAYOUT, 0.25 * frameRate);
    scon.addId(this, STATE_HOLD, 2.1 * frameRate);
    scon.addId(this, STATE_DISMISS, 0.24 * frameRate);
  }

  PImage findBusySpotOfImage (PImage img, float w, float h) {

    img.loadPixels();
    int px = 0, py = 0;
    float brightness = 0;

    while (brightness < 155) {
      px = (int)random(0, width - w);
      py = (int)random(0, height - h);

      color c = img.pixels[px + py * width];
      brightness = brightness(c);
    }

    PImage result = img.get(px, py, (int)w, (int)h);
    result.resize(int(w*random(1.2,4)), int(h*random(1.2,4)));
    return result.get(0,0,(int)w,(int)h);
  }

  void createSubwindowsLayout() {
    float w = 100;
    float h = w * 3 /4.0;
    float margin = 10;
    float x = bound.width - w - margin;
    float y =  + margin;

    saveFrame(SAVED_FRAME_NAME);
    PImage img = loadImage(SAVED_FRAME_NAME);

    for (int i=0; i < this.subwindows.size(); i++) {
      Subwindow s = this.subwindows.get(i);

      s.setImage(  findBusySpotOfImage(img, w, h) );
      s.startX = (int)x;
      s.startY = int(-h-y);
      s.endX = (int)x;
      s.endY = (int)(i * (h + margin));

      s.setDuration(0.3);
    }
  }

  void draw(PGraphics g) {
    if (super.hidden) return;

    localG = createGraphics(bound);
    localG.beginDraw();
    localG.tint(255, 185);
    pmover.draw(localG);
    localG.endDraw();


    drawOn(localG, g, bound);

    scon.tick();
  }

  void callbackWith(StateSequenceController sc, State s, PGraphics g) {
    this.state = s.stateId;
    println("state:" + this.state);
    if (this.state == STATE_WAIT) {
      //do nothing
    } else if (this.state == STATE_HOLD) {
      //do nothing
    } else if (this.state == STATE_LAYOUT) {
      createSubwindowsLayout();
    } else if (this.state == STATE_DISMISS) {
      clearSubwindows();
    }
  }

  void clearSubwindows() {
    float w = 100;
    float h = w * 3 /4.0;
    float margin = 10;
    float x = bound.width - w - margin;
    float y = -h-w;


    for (int i=0; i < this.subwindows.size(); i++) {
      Subwindow s = this.subwindows.get(i);
      s.startX = (int)s.nowX;
      s.startY = (int)s.nowY;
      s.endX = (int)x;
      s.endY = (int)y;

      s.setDuration(0.3);
    }
  }

  void bang() {
    clearSubwindows();
  }
}
