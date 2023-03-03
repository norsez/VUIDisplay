class LayoutA extends AbstractLayout {
  
  float secsToSwitch = 2;
  float curFrame;
  float dxToSwitch;
  
  PGraphics [] dgs;
  int maxSubWindows = 4;
  int maxLayers = 4;
  int minLayers = 2;
  int curLayer; //
  Set<PGraphics> bgDisplays;
  ArrayList<Set<PGraphics>> subWindows;
  List<ARect> subWindowRects;
  
  
  LayoutA(ARect b, List<DisplayInterface> dis) {
    super(b,dis);
    dgs = new PGraphics [dis.size()];
    for(int i=0; i< dgs.length; i++) {
        dgs[i] = createGraphics(b);
    }
    
    dxToSwitch = secsToSwitch * frameRate;
    
    this.shuffleDisplays();
  }
  
  void draw(PGraphics g) {
    
    if (curFrame >= dxToSwitch) {
      shuffleDisplays();
      curFrame = 0;
    }
    
    for(int i=0; i< super.displays.size(); i++) {
       dgs[i].beginDraw();
       displays.get(i).draw(dgs[i]); 
       dgs[i].endDraw();
    }
    g.background(0,40);
    drawBg(g);
    drawSubWindows(g);
    
    curFrame++;
  }
  
  
  
  Set<PGraphics> randomBuffer() {
    Set<PGraphics> s = new HashSet();
    int numDis = (int) random(minLayers,maxLayers+1);
    while (s.size() < numDis) {
      s.add(dgs[curLayer++]);
      if (curLayer >= dgs.length) {
        curLayer = 0;
      }
    }  
    
    return s;
  }
  
  void drawSubWindows(PGraphics g) {
    g.push();
    for(int i=0; i< subWindows.size();i++){
      g.tint(255,180);
      //g.blendMode(ADD);
      Set<PGraphics> sw = subWindows.get(i);
      ARect r = subWindowRects.get(i);
      g.stroke(colorFromMap(), random(100,150));
      g.strokeWeight(3);
      g.fill(0,24);
      g.rect(r.originX, r.originY, r.width, r.height,8);
      for(int j=0; j< sw.size(); j++) {
        PGraphics b = (PGraphics)sw.toArray()[j];
        g.image(b,r.originX,r.originY,r.width,r.height);
      }
      g.fill(colorFromMap(), 220);
      g.textSize(6);
      g.text("symphony", r.originX + 2, r.originY+ 8);
      
    }
    g.pop();
     
  }
  
  void drawBg(PGraphics g) {
    g.push();
    g.background(0, 25);
    g.blendMode(ADD);
    g.tint(255,175);
    debug("bg displays: " + bgDisplays.size() + ", subw:" + subWindows.size(), 20,100,g);
    for(int i=0; i< bgDisplays.size(); i++) {
      PGraphics b = (PGraphics)bgDisplays.toArray()[i];
      g.image(b,0,0);
    }
    g.pop();
  }
  
  void toggleAuto(){
    super.toggleAuto();
    Collections.shuffle(this.displays);
    this.shuffleDisplays();
    
  }
  
  void shuffleDisplays(){
    bgDisplays = randomBuffer(); //<>//
    
    subWindows = new ArrayList();
    int numSubWindows = (int)random(2, maxSubWindows);
    for(int i=0; i< numSubWindows; i++) {
      subWindows.add(randomBuffer());
    }
    subWindowRects = randomRects(numSubWindows);
    
  }
  
  List<ARect> randomRects(int num) {
    List<ARect> results = new ArrayList();
    //for(int i=0; i<num; i++) {
    //  ARect a = new ARect(int(random(0,bound.width * 0.2)),
    //        int(random(0,bound.height * 0.2)),
    //        int(random(30, bound.width* 0.4)),
    //        int(random(30, bound.height * 0.4))
    //        );
    // results.add(a);       
    //}
    float x = 10;
    float y = 10;
    float margin = 2;
    ARect a = new ARect(x,y, bound.width * 0.25, bound.height * 0.2); 
    results.add(a);
    y += a.height + margin;
    ARect b = new ARect(x,y, bound.width * 0.25, bound.height * 0.2); 
    results.add(b);
    y += b.height + margin;
    ARect c = new ARect(x,y, bound.width * 0.25, bound.height * 0.2); 
    results.add(c);
    y += c.height + margin;
    ARect d = new ARect(x,y, bound.width * 0.25, bound.height * 0.2);
    results.add(d);
    y += d.height + margin;
    return results;
  }
}
