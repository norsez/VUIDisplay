class DisplayRunningWave extends AbstractDisplay {
  PGraphics localG, prevG;
  float margin_x = 2;
  
  DisplayRunningWave(ARect bound) {
    super(bound);
    
  }

  void draw(PGraphics g) {

    if (super.hidden) return;

    localG = createGraphics((int)this.bound.width, (int)this.bound.height);
    localG.beginDraw();
    localG.background(0, 20);
    if (prevG != null) {
      localG.image(prevG, -margin_x * 2, 0);
    }

    float x = localG.width - (margin_x * 2);
    float y = map(waveform.data[0] * mapCurve( ampsum, 2), -1, 1, localG.height, 0);
    
    
    drawLineSimple(x, localG.height * 0.5, x, y, localG);

    localG.endDraw();
    prevG = localG;
    g.tint(255, 200 * mapCurve(ampsum,2));
    g.image(localG, 0, 0);
    g.noTint();
  }
  
  void drawLineSimple(float fromX, float fromY, float toX, float toY, PGraphics g) {
    float ca = norm(constrain(controlA, -100,100), -100,100);
    localG.stroke(colorFromMap(int(fromX), int(toY), bound), 120 + 80 * ampsum);
    localG.strokeWeight(margin_x + ca * 50);

    localG.line(  fromX
      , fromY
      , toX
      , toY);
  }
  
  void drawLineBling(float fromX, float fromY, float toX, float toY, PGraphics g) {
    
    for (int i=0; i< 25; i++){
       color c = colorFromMap((int)random(fromX, toX), (int)random(fromY, toY), bound);
       g.fill(c, 100);
       g.noStroke();
       float centerX = random(fromX, toX);
       float centerY = random(toY, fromY);
       float radius = random(2,25);
       g.ellipse(centerX, centerY, radius, radius);
    }
  }
  
}
