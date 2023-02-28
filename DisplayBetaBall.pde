


class DisplayBetaBall extends AbstractDisplay {
  PGraphics lg;
  DisplayBetaBall(ARect bound) {
    super(bound);
    lg = createGraphics(super.bound);
  }
  
  void draw(PGraphics g) {
    
    if (super.hidden) return;
  
    lg.beginDraw();
    lg.background(0, 55);
    int bands = int(fft.spectrum.length * 0.2);
    int spacing = (int)( bound.width / float(bands));
    lg.textSize(8);
    for (int i=0; i< bands; i++){
      
      lg.text("" + withMathRound(fft.spectrum[i],2), spacing * i, 10 + bound.height * fft.spectrum[i]);
    }
    lg.endDraw();
    
    
    super.drawOn(lg,g,super.bound);
  }
  
  
  
}
