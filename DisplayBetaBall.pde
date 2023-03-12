


class DisplayBetaBall extends AbstractDisplay {
  
  
  float partOfFFT = 0.1;
  float topFreq;
  int bands, spacing;
  List<Easing> easings;
  int skipFrame = 10;
  PGraphics lg;
  
  DisplayBetaBall(ARect bound) {
    super(bound);
    lg = createGraphics(super.bound);
    this.topFreq = 22000.0 * partOfFFT;
    bands = int(FFT_NUM_BANDS * partOfFFT);
    spacing = (int)( bound.width / float(bands));
    easings = new ArrayList();
    for (int i=0; i < bands; i++){
      Easing e = new Easing();
      e.easing = 0.07;
      easings.add(e);
    }
  }
  
  void draw(PGraphics g) {
    
    if (super.hidden) return;
    
    //if (frameCount % skipFrame !=0) {
    //  lg.beginDraw();
    //  lg.endDraw();
    //  drawOn(lg,g,super.bound);
    //  return;
    //}
    
    lg = createGraphics(bound);
    lg.beginDraw();
    for (int i=1; i< bands + 1; i++){
      
      lg.fill( colorFromMap(spacing * i, 40, bound), 150 + fft.spectrum[i]*200 );
      lg.textSize(4 + 4*fft.spectrum[i]);
      //lg.text("" + withMathRound(fft.spectrum[i],2), spacing * i, 10 + bound.height * fft.spectrum[i]);
      easings.get(i-1).easing = mapCtrlA(0.05, 0.7);
      lg.text(formatFreq(map(i,1,bands + 1,20,this.topFreq), 1), 
          spacing * i, 
          easings.get(i-1).ease(10 + bound.height * fft.spectrum[i]));
    }
    lg.endDraw();
    
    
    drawOn(lg,g,super.bound);
  }
  
   //<>//
  
}
