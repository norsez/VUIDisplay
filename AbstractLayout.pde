abstract class AbstractLayout {
  List<DisplayInterface> displays;
  ARect bound;
  
  boolean isAuto;
  
  void toggleAuto() {
    isAuto = !isAuto;
    println(isAuto?"is auto layout":"");
  }
  
  AbstractLayout(ARect bound, List<DisplayInterface> dis){
    this.displays = dis;
    this.bound = bound;
  }
  
  abstract void draw(PGraphics g);
  void bang() {
    for(DisplayInterface d: this.displays) {
      d.bang();
    }
  }
}
