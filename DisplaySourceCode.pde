class DisplaySourceCode extends AbstractDisplay {
  String FILE_NAME = "sourcecode.txt";
  String [] lines;
  float fontSize = 8;
  float waitDx;
  float curFrame = 0;
  int lineIndex = 0;
  PGraphics lg;
  float y = 0;
  float lineSpacing = 0;
  float inset = 8;
  
  
  DisplaySourceCode(ARect b) {
    super(b);
    lines = loadStrings(FILE_NAME);
    waitDx = 0.025 * frameRate;
    lg = createGraphics(b);
  }
  
  void draw(PGraphics g) {
    if(super.hidden) return;
    
    if (lineIndex >= lines.length){
      lineIndex = 0;
    }
    
    lg.beginDraw();
    lg.textSize(fontSize);
    if (curFrame >= waitDx) {
      curFrame = 0;
      lg.fill(0,250);
      lg.rect(inset,0, bound.width, fontSize + inset + lineSpacing);
      
      lg.fill(colorFromMap());
      lg.noStroke();
      lg.text(lines[lineIndex++], bound.width * 0.6 + inset, y); 
      y += inset + lineSpacing;
      
      
      if (y > bound.height - inset) {
        y = inset;
        lg.background(0, 100);
        curFrame = 0;
      }
    }
    
    curFrame++;
    
    lg.endDraw();
    
    drawOn(lg,g,bound);
  }
}
