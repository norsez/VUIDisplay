


class DisplayBetaBall extends AbstractDisplay {
  
  DisplayBetaBall(ARect bound) {
    super(bound);
    
  }
  
  void draw(PGraphics g) {
    
    if (super.hidden) return;
    PGraphics lg = createGraphics(super.bound);
    lg.beginDraw();
    //lg.background(0, 35);
    int bands = int(fft.spectrum.length * 0.2);
    int spacing = (int)( bound.width / float(bands));
    
    for (int i=1; i< bands + 1; i++){
      lg.fill( colorFromMap(spacing * i, 40, bound), 150 + fft.spectrum[i]*200);
      lg.textSize(4+ 3*fft.spectrum[i]);
      lg.text("" + withMathRound(fft.spectrum[i],2), spacing * i, 10 + bound.height * fft.spectrum[i]);
    }
    lg.endDraw();
    
    
    super.drawOn(lg,g,super.bound);
  }
  
  
  
}
