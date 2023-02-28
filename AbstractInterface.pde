
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

  
  
  void draw(PGraphics g) {
    print("implement me");
  }
  
  
  
}
