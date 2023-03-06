 
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
    g.stroke(colorFromMap(int(sx), int(sy), true), 215);
    g.strokeWeight(this.weight);
    g.line(sx, sy, ex, ey);
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

  DisplayBarWaveForm(ARect bound) {
    super(bound);

    y1 = bound.height * 0.47;
    y2 = bound.height * 0.52;
    y1_10 = bound.height * 0.45;
    y2_10 = bound.height * 0.55;
    space_width = bound.width / float(MAX_BARS);
    ph_space_width = space_width / 5.0;
  }

  void updateGraphData() {
  }
 
  void draw(PGraphics g) {
    if (super.hidden) return;

    PGraphics localG = createGraphics(g.width, g.height);
    localG.beginDraw();
    
    


    //draw last frame 
    PGraphics g_1 = createGraphics(localG.width, localG.height);
    g_1.beginDraw();
    g_1.image(g, 0, 0);
    g_1.endDraw();
    localG.tint(0,55);
    
    localG.image(g_1
      , int((g_1.width - localG.width) * 0.5)
      , int((g_1.height - localG.height) * 0.5)
      , int(g_1.width * 1.1)
      , int(g_1.height * 1.1)
      );
      
    //draw placeholding
    localG.stroke(this.C_PLACEHOLDER);
    localG.strokeWeight(0.02);
    
    int total_ticks_pl = int(localG.width / ph_space_width);
    for (int i=0; i< total_ticks_pl; i++) {
       if (i % 10 == 0) {
         localG.line(ph_space_width * i, y1_10, ph_space_width* i, y2_10);
       }else {
         localG.line(ph_space_width * i, y1, ph_space_width* i, y2);
       }
    }


    //draw this frame

    for (int i=0; i< MAX_BARS; i++) {
      LineB1 ball = new LineB1(space_width *i,
        g.height - map(waveform.data[i], -1, 1, g.height, 0),
        space_width * i,
        map(waveform.data[i], -1, 1, g.height, 0)
        );
      ball.weight = maxWeight * mapCurve(abs(waveform.data[i]), 4);
      ball.draw(localG);
     
    }

    localG.endDraw();
    
    drawOn(localG, g, bound);
    
    updateParams();
  }
  
  void updateParams() {
    maxWeight = map(constrain(int(controlA), -100, 100), -100, 100, 1.5, 20);
  }
}
