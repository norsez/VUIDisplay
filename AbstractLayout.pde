abstract class AbstractLayout {
  List<DisplayInterface> displays;
  ARect bound;
  
  //starts true so the spotlight rotates from the first frame. it used to default to
  //false, which left the rotation switched off until Z was pressed - and a press
  //that switched it back off printed an empty string, so Z looked like a dead key
  boolean isAuto = true;
  
  void toggleAuto() {
    isAuto = !isAuto;
    //both states say something. the old "" on the way down read as silence
    println(isAuto ? "spotlight rotation ON" : "spotlight rotation OFF");
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
