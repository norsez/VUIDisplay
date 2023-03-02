abstract class AbstractLayout {
  List<DisplayInterface> displays;
  ARect bound;
  AbstractLayout(ARect bound, List<DisplayInterface> dis){
    this.displays = dis;
    this.bound = bound;
  }
  
  abstract void draw(PGraphics g);
}
