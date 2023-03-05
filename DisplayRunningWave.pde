class DisplayRunningWave extends AbstractDisplay {
  PGraphics localG, prevG;
  float margin_x = 2;
  Easing easing;
   DisplayRunningWave(ARect bound) {
    super(bound);
    easing = new Easing();
    easing.easing = 0.25;
  }

  void draw(PGraphics g) {

    if (super.hidden) return;

    localG = createGraphics((int)this.bound.width, (int)this.bound.height);
    localG.beginDraw();
    if (prevG != null) {
      localG.image(prevG, -margin_x * 2, 0);
    }

    float x = localG.width - (margin_x * 2);
    float y = map(easing.ease(waveform.data[0]) * mapCurve( ampsum, 2), -1, 1, localG.height, 0);
    drawLineSimple(x, localG.height * 0.5, x, y, localG);

    localG.endDraw();
    prevG = localG;
    //g.tint(255, 200 * mapCurve(ampsum,2));
    g.image(localG, 0, 0);
    g.noTint();
  }
  
  void drawLineSimple(float fromX, float fromY, float toX, float toY, PGraphics g) {
    //float ca = mapCtrlA(1,5);
    easing.easing = mapCtrlA(0.7,.3);
    float ctrlA = mapCtrlA(0,1);
    localG.stroke(colorFromMap(int(fromX), int(toY), bound), 200 + ctrlA * 140 * ampsum);
    localG.strokeWeight( ctrlA * margin_x + 2);

    localG.line(  fromX
      , fromY
      , toX
      , toY);
    localG.fill( colorFromMap(), 150);
    localG.noStroke();
    localG.rect( toX, toY, 4, 2);
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
