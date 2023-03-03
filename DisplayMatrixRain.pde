String matrixChars;

class RainLine {
  
  final int ACT_WAIT = 0, ACT_POPULATE = 1, ACT_STAY = 2, ACT_DELETE = 3;
  
  int action = 0;
  float rainHeight;
  float rainWidth;
  ARect bound;
  List<String>ch;
  float waitFrames = 0;
  float populateFrames = 0;
  float stayFrames, deleteFrames = 0;
  float curFrame = 0;
  float charFrames = 0; // frames per char in populate
  
  
  RainLine(ARect b, float rainWidth) {
    this.rainWidth = rainWidth;
    this.bound = b;
    rainHeight = random(b.height * 0.35, b.height * 0.76);
    waitFrames = random(0.4,1.1) * frameRate;
    populateFrames = random(1.5,2.2) * frameRate;
    stayFrames = random( 2,5) * frameRate;
    deleteFrames = random(0.4, 0.8) * frameRate;
    calcChars();
  }
  
  void calcChars() {
    ch = new ArrayList();
    for(int i=0; i < int(rainHeight/rainWidth); i++) {
      int index = (int)random(0,matrixChars.length() - 1);
      ch.add(matrixChars.substring(index,index+1));
    }
    
    charFrames = populateFrames/ch.size();
  }
  
  void draw(PGraphics g) {
    
     switch(action){
       case ACT_WAIT: doWait(g);
       case ACT_POPULATE: doPopulate(g);
       case ACT_STAY: doStay(g);
       case ACT_DELETE: doDelete(g);
       
     }
  }
  
  void doWait(PGraphics g) {
    curFrame++;
    if (curFrame >= waitFrames) {
      curFrame = 0;
      action = ACT_POPULATE;
      calcChars();
    }
  }
  
  void doPopulate(PGraphics g) {
   
    if  (int(curFrame) % charFrames == 0) {
      g.push();
      g.fill(0,24);
      g.rect(0,0,rainWidth, rainHeight);
      g.textSize(rainWidth);
      
      g.pop();
    }
    curFrame++;
    if (curFrame >= waitFrames) {
      curFrame = 0;
      action = ACT_STAY;
    }
  }
  
  void doStay(PGraphics g) {
    
    curFrame++;
    if (curFrame >= waitFrames) {
      curFrame = 0;
      action = ACT_DELETE;
    }
  }
  
  void doDelete(PGraphics g) {
    
    curFrame++;
    if (curFrame >= waitFrames) {
      curFrame = 0;
      action = ACT_WAIT;
    }
  }
}

class DisplayMatrixRain extends AbstractDisplay {
  
  
  String FILE_NAME = "thaichars.txt";
  List<RainLine> rainLines;
  float rainLineWidth = 14;
  int rainLineNum = 0;
  
  DisplayMatrixRain(ARect b){
    super(b);
    String [] lines = loadStrings(FILE_NAME);
    matrixChars = lines[0];
    calcRainLines();
  }
  
  void calcRainLines () {
    rainLines = new ArrayList();
    this.rainLineNum = int(bound.width/ rainLineWidth);
    for(int i=0; i< this.rainLineNum; i++) {
      RainLine rl = new RainLine(super.bound, rainLineWidth);
      
      rainLines.add(rl);
    }
  }
  
  void draw(PGraphics g) {
    if (super.hidden) return;
    
    PGraphics lg = createGraphics(bound);
    lg.beginDraw();
     lg.push();
    for (RainLine rl: this.rainLines) {
      rl.draw(lg);
      lg.translate(rainLineWidth,0);
    }
    lg.endDraw();
    lg.endDraw();
    drawOn(lg,g,bound);
    
  }
  
}
