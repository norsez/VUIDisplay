class DisplayRunningWave extends AbstractDisplay {
  PGraphics localG, prevG;
  float margin_x = 2;
  int w, h;
  DisplayRunningWave(int w, int h) {
    this.w = w;
    this.h = h;
  }

  void draw(PGraphics g) {

    if (super.hidden) return;

    localG = createGraphics(this.w, this.h);
    localG.beginDraw();

    if (prevG != null) {
      localG.image(prevG, -margin_x * 2, 0);
    }

    float x = localG.width - (margin_x * 2);
    float y = map(waveform.data[0] * mapCurve( ampsum, 2), -1, 1, localG.height, 0);
    localG.stroke(colorFromMap(int(x), int(y), true), 180);
    localG.strokeWeight(margin_x);

    localG.line(  x
      , localG.height * 0.5
      , x
      , y);


    localG.endDraw();
    prevG = localG;
    g.tint(255, 200 * mapCurve(ampsum,2));
    g.image(localG, 0, 0);
    g.noTint();
  }
}
