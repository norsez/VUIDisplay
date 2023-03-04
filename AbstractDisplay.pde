
color COLOR_GREEN = color(0,180,0,100);

abstract class AbstractDisplay implements DisplayInterface {
  boolean hidden; 
  ARect bound;
  
  AbstractDisplay(ARect bound) {
    this.bound = bound;
  }
  
  void toggleHidden() {
    this.hidden = !hidden;
  }
  
  boolean isHidden() {
    return hidden;
  }
  
  void setHidden(boolean h) {
    this.hidden = h;
  }

  void draw(PGraphics g) {
    g.push();
    g.textSize(50);
    g.fill(255,100,222);
    g.text("Implement Me", 1,51);
    g.pop();
  }
  
  void drawOn(PGraphics localG, PGraphics mainG, ARect bound) {
    drawOn(localG, mainG, bound, 150);
  }
  void drawOn(PGraphics localG, PGraphics mainG, ARect bound, int alpha) {
     
    mainG.push();
    //mainG.background(0, 1);
    //mainG.tint(255,alpha);
    
    mainG.image(localG, bound.originX, bound.originY, bound.width, bound.height);
    
    mainG.pop();
  }
  
  float mapCtrl(float controlValue, float min, float max) {
    return map(controlValue, MIN_CONTROL, MAX_CONTROL, min, max);
  }
  
  float mapCtrlA(float min, float max) {
    return mapCtrl(controlA, min, max);
  }
}
