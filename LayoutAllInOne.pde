class LayoutAllInOne extends AbstractLayout {
  int maxDisplays = 5;
  int fullAlphaLayer = 0;
  LayoutAllInOne(ARect bound, List<DisplayInterface> dis) {
    super(bound,dis);
    
  }
  
  float switchFrame, nextSwitch = 0;
  
  void draw(PGraphics g) {
    PGraphics lg = createGraphics(bound);
    lg.beginDraw();
    lg.background(0);
    if (super.isAuto) {
      if (switchFrame >= nextSwitch) {
        calcNextSwitch();
      }
    }
    
    lg.push();
    for(int i=0; i<displays.size(); i++){
      DisplayInterface d = displays.get(i);
      
     
      
      d.draw(lg);
      
    }
    lg.pop();
    lg.endDraw();
    
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
        
        List<Integer>unHiddenIndices = new ArrayList();
        for (int i=0; i < hiddens.length; i++){
          this.displays.get(i).setHidden(hiddens[i]);
          if (hiddens[i] == false) {
            unHiddenIndices.add(i);
          }
        }
        Collections.shuffle(unHiddenIndices);
        this.fullAlphaLayer = unHiddenIndices.size()==0?0: unHiddenIndices.get(0);
        
        println("full alpha layer: " + fullAlphaLayer);
        println("unhiidden: " + unHiddenIndices);
        
  }
}
