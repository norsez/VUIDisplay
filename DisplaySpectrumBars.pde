class DisplaySpectrumBars extends AbstractDisplay { //<>// //<>// //<>//
  final int HORIZONTAL = 0, VERTICAL = 1;
  int orientation = 0;
  color C_BAR_PLACEHOLDER = color(191, 203, 198, 8);
  int numBars  = 16;
  int barMargin = 2;
  float spectrumMultiplier = 12;
  int steps = 50;
  float inset = 24;
  PGraphics lg;

  Easing [] easings;
  Easing [] easingMeters;
  color [] barColors;

  float _alphaCtrlA, _hCtrlA;

  DisplaySpectrumBars(ARect b) {
    super(b);
    lg = createGraphics(b);
    easings = new Easing [numBars];
    easingMeters = new Easing [numBars];
    barColors = new color [numBars];
    for (int i=0; i< easings.length; i++) {
      easings[i] = new Easing();
      easings[i].easing = 0.05;
      easingMeters[i] = new Easing();
      easingMeters[i].easing = 0.01;
      barColors[i] = colorFromMap();
    }
  }

  void draw(PGraphics g) {
    if (super.hidden) return;
    lg = createGraphics(bound);
    lg.beginDraw();
    
    float barWidth = (bound.width / numBars) - barMargin * 2;

    lg.push();
    //lg.blendMode(ADD);
    //lg.tint(255,190);
    float stepSpacing = (bound.height) / steps;

    for (int i=0; i< steps; i++) {
      lg.translate(0, stepSpacing);
      lg.stroke(0);
      lg.strokeWeight(0.5);
      lg.line(0, 0, bound.width, 0);
    }
    lg.pop();

    lg.push();
    //lg.blendMode(ADD);
    //lg.tint(255,190);
    for (int i=0; i< numBars; i++) {
      lg.noStroke();
      lg.fill(this.C_BAR_PLACEHOLDER, 40);
      lg.translate(barMargin, 0);
      lg.rect(0, 0, barWidth, bound.height);
      lg.translate(barWidth, 0);
    }
    lg.pop();

    lg.push();
    //lg.blendMode(ADD);
    //lg.tint(255,190);
    for (int i=0; i< numBars; i++) {

      lg.noStroke();

      lg.translate(barMargin, 0);
      float h = fft.spectrum[i * numBars] * bound.height * spectrumMultiplier;
      h = h * _hCtrlA;
      lg.push();
      
      lg.translate(0, bound.height - h);
      lg.fill(barColors[i]);
      lg.rect(0, 0, barWidth, h);
      lg.pop();
      
      lg.push();
      lg.translate(0, easingMeters[i].ease(bound.height-h));
      
      lg.fill(barColors[i], 200);
      lg.textSize(7);
      lg.text(round(cvLinearTodB(fft.spectrum[i * numBars])) + "dB", 0, 0);
      lg.pop();

      lg.translate(barWidth, 0);
    }
    lg.pop();
    lg.endDraw();


    ARect insetBound = new ARect(bound.originX + inset, bound.originY + inset, bound.width - inset*2, bound.height - inset*2);
    
    g.push();
    g.tint(255, _alphaCtrlA * ampsum);
    drawOn(lg, g, insetBound);
    g.pop();
    updateParams();
  }

  void updateParams() {
    if (frameCount % APP_PARAM_UPDATE_RATE != 0) return;
  
    _alphaCtrlA = 100 + mapCtrlA(9, 130);
    _hCtrlA = mapCtrlA(0.45, 1);
  }

  void bang() {
    for (int i=0; i< easings.length; i++) {
      barColors[i] = colorFromMap();
    }
  }
}