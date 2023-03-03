class LayoutAllInOne extends AbstractLayout {
  int maxDisplays = 5;
  
  LayoutAllInOne(ARect bound, List<DisplayInterface> dis) {
    super(bound,dis);
    
  }
  
  float switchFrame, nextSwitch = 0;
  
  void draw(PGraphics g) {
    PGraphics lg = createGraphics(bound);
    lg.beginDraw();
    lg.blendMode(ADD);
    lg.tint(255,200);
    if (super.isAuto) {
      if (switchFrame >= nextSwitch) {
        calcNextSwitch();
      }
    }
    
    
    for(DisplayInterface d: displays){
      d.draw(lg);
    }
    lg.endDraw();
    g.background(0, 15);
    g.image(lg,bound.originX,bound.originY,bound.width, bound.height);
    
    switchFrame += 1;
    
    
    //debug(switchFrame +"/"+nextSwitch, width - 200, height - 30, g);
  }
  
  void toggleAuto(){
    super.toggleAuto();
    calcNextSwitch();
    
  }
  
  void calcNextSwitch() {
    nextSwitch = frameCount * random (1.7, 2.7);  
        switchFrame = 0;
        
        int notHidden = 0;
        boolean [] hiddens = new boolean [displays.size()];
        for (int i=0; i< hiddens.length; i++) {
           hiddens[i] = random(0,100) > 50;
           if (hiddens[i] == false) notHidden++;
           if (notHidden >= maxDisplays) {
             for (int j = i+1; j < hiddens.length; j++){
               hiddens[j] = true;
             }
             break;
           }
        }
        
        for (int i=0; i < hiddens.length; i++){
          this.displays.get(i).setHidden(hiddens[i]);
        }
  }
}
