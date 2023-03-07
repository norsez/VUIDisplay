 
class LineB1 {
  float weight = 3;
  float sx, sy, ex, ey;
  LineB1(float startX, float startY, float endX, float endY) {
    sx = startX;
    sy = startY;
    ex = endX;
    ey = endY;
  }

  void draw(PGraphics g) {
    color c = colorFromMap(int(sx), int(sy), true);
    g.stroke(c, 215);
    g.strokeWeight(this.weight);
    g.line(sx, sy, ex, ey);
  
    for(int i=0; i<(int)random(4,15); i++){
      g.fill(c, random (20,80));
      g.noStroke();
      g.rect(random(sx,ex), random(sy,ey), random(1,4), random(1,6), 3);
    }
  }
}


class DisplayBarWaveForm extends AbstractDisplay {
  int graphIndex;
  int MAX_BALLS_PER_BAR = 64;
  int MAX_BARS = NUM_SAMPLES_WAVE;
  
  int MAX_BALLS = 100;
  
  float maxWeight = 3;
  
  final color C_PLACEHOLDER = color(101,113,106, 72);

  float y1;
  float y2;
  float y1_10;
  float y2_10;
  float ph_space_width, space_width;
  Easing [] easings;

  DisplayBarWaveForm(ARect bound) {
    super(bound);

    y1 = bound.height * 0.47;
    y2 = bound.height * 0.52;
    y1_10 = bound.height * 0.45;
    y2_10 = bound.height * 0.55;
    space_width = bound.width / float(MAX_BARS);
    ph_space_width = space_width / 5.0;
    easings = new Easing [MAX_BARS];
    for(int i=0; i< MAX_BARS; i++) {
      easings[i] = new Easing();
      easings[i].easing = 0.25;
      easings[i].lastValue = 0.5;
    }
    
  }
  
  void draw(PGraphics g) {
    if (super.hidden) return;

    PGraphics localG = createGraphics(g.width, g.height);
    localG.beginDraw();

    //draw this frame
    for (int i=0; i< MAX_BARS; i++) {
      easings[i].easing = _easingCtrlA;
      float dataPoint = easings[i].ease(waveform.data[i]);

      LineB1 ball = new LineB1(space_width *i,
        g.height - map(dataPoint, -1, 1, g.height, 0),
        space_width * i,
        map(dataPoint, -1, 1, g.height, 0)
        );
      ball.weight = maxWeight * mapCurve(abs(dataPoint), 4);
      ball.draw(localG);
    }

    localG.endDraw();
    
    drawOn(localG, g, bound);
    
    updateParams();
  }

  float _easingCtrlA;
  
  void updateParams() {
    maxWeight = mapCtrlA(1.5, 30);
    _easingCtrlA = mapCtrlA(0.025,0.7);
  }
  
  void bang() {
    for(int i=0; i< MAX_BARS; i++) {
      easings[i].lastValue = i%2 == 0 ? -1:1;
    }
  }
}
