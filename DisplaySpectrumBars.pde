class DisplaySpectrumBars extends AbstractDisplay {
    int HORIZON = 0, VERTICAL = 1;
    int orientation = HORIZON;
    color C_BAR_PLACEHOLDER = color(191,203,198, 8);
    int numBars  = 16;
    int barMargin = 2;
    int numStepsPerSubBar = 20;
    int subBarMargin = 1;
    PGraphics lg;
    
    DisplaySpectrumBars(ARect b) {
      super(b);
      lg = createGraphics(b);
    }
    
    void draw(PGraphics g) {
      if (super.hidden) return;
      lg.beginDraw();
      lg.background(0, 5);
      
      
      float barWidth = (bound.width / numBars) - barMargin * 2;
      
      lg.push();
      for(int i=0; i< numBars; i++) {
        lg.noStroke();
        lg.fill(this.C_BAR_PLACEHOLDER);
        lg.translate(2,0);
        lg.rect(0,0, barWidth, bound.height);
        lg.translate(barWidth, 0);
      }
      lg.pop();
      
      
      for(int i=0; i< numBars; i++) {
        lg.noStroke();
        lg.fill(colorFromMap(), 50 + 145 * ampsum);
        lg.translate(2,0); 
        float h = fft.spectrum[i * numBars] * bound.height;
        lg.push();
        lg.translate(0,bound.height - h);
        lg.rect(0,0, barWidth, h);
        lg.pop();
        lg.translate(barWidth, 0);
      }
      
      
      lg.endDraw();
      
      drawOn(lg,g,bound);
    }
}
