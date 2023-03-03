class DisplaySpectrumBars extends AbstractDisplay {
    final int HORIZONTAL = 0, VERTICAL = 1;
    int orientation = 0;
    color C_BAR_PLACEHOLDER = color(191,203,198, 8);
    int numBars  = 16;
    int barMargin = 2;
    float spectrumMultiplier = 12;
    int steps = 100;
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
      float stepSpacing = (bound.height) / steps;
      int alpha = 25;
      for (int i=0; i< steps; i++){
        lg.translate(0, stepSpacing);
        if(i % 5 ==0)alpha = 80; else alpha = 40;
        lg.stroke(0, alpha);
        lg.strokeWeight(0.5);
        lg.line(0,0,bound.width,0);
      }
      lg.pop();
      
      lg.push();
      for(int i=0; i< numBars; i++) {
        lg.noStroke();
        lg.fill(this.C_BAR_PLACEHOLDER);
        lg.translate(barMargin,0);
        lg.rect(0,0, barWidth, bound.height);
        lg.translate(barWidth, 0);
        
      }
      lg.pop();
      
      lg.push();
      for(int i=0; i< numBars; i++) {
        
        lg.noStroke();
        
        lg.translate(barMargin,0); 
        float h = fft.spectrum[i * numBars] * spectrumMultiplier * bound.height;
        lg.push();
        lg.translate(0,bound.height - h);
        lg.fill(color(81,216,172), 4 + 80 * ampsum);
        lg.rect(0,0, barWidth, h);
        lg.pop();
        lg.translate(barWidth, 0);
      }
      lg.pop();
      
      
      
      lg.endDraw();
      
      if (orientation == VERTICAL) {
        PGraphics vg = createGraphics(bound);
        vg.beginDraw();
        vg.push();
        float sx = float(vg.width) / lg.height;
        float sy = float(vg.height)/ lg.width;
        vg.scale(sx,sy);
        vg.rotate(radians(90));
        vg.translate(0,-vg.height);
        vg.image(lg,0,0);
        vg.endDraw();
        vg.pop();
        
        lg.beginDraw();
        
        lg.background(0, 25);
        
        debug("sx: " + sx + ", sy: " + sy, 20, 20, lg);
        
        lg.image(vg,0,0);
        lg.endDraw();
      }
      
      
      ARect insetBound = new ARect(bound.originX + inset, bound.originY + inset, bound.width - inset*2, bound.height - inset*2);
      drawOn(lg,g,insetBound);
    }
    
    
}
