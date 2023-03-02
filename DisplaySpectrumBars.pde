class DisplaySpectrumBars extends AbstractDisplay {
    color C_BAR_PLACEHOLDER = color(191,203,198, 8);
    int numBars  = 16;
    int barMargin = 2;
    float spectrumMultiplier = 12;
    float inset = 24;
    PGraphics lg;
    
    DisplaySpectrumBars(ARect b) {
      super(b);
      lg = createGraphics(b);
    }
    
    void draw(PGraphics g) {
      if (super.hidden) return;
      lg.beginDraw();
      lg.background(0, 25);
      
      
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
        
        lg.translate(2,0); 
        float h = fft.spectrum[i * numBars] * spectrumMultiplier * bound.height;
        lg.push();
        lg.translate(0,bound.height - h);
        lg.fill(color(81,216,172), 50 + 50 * ampsum);
        lg.rect(0,0, barWidth, h);
        lg.pop();
        lg.translate(barWidth, 0);
      }
      
      
      lg.endDraw();
      ARect insetBound = new ARect(bound.originX + inset, bound.originY + inset, bound.width - inset*2, bound.height - inset*2);
      drawOn(lg,g,insetBound);
    }
}
