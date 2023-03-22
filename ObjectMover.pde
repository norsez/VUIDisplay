
abstract class Movable {
  int startX, startY, nowX, nowY;
  int endX, endY;
  float curFrames, dxFrames;
  PImage gToMove;
  boolean done = false;
  
  void setDuration(float secs) {
    curFrames = secs * frameRate;
    dxFrames = 1.0/curFrames;
    done = false;
  }

  void draw(PGraphics g) {
    
    if(this.gToMove == null) return;

    if (!done) {
      float curRatio =  1.0 -( curFrames * dxFrames );
      nowX = (int)lerp(startX, endX, curRatio);
      nowY = (int)lerp(startY, endY, curRatio);
    }
    
    g.image(gToMove, nowX, nowY);

    curFrames--;
    done = (curFrames <= 0);
  }
}

class ObjectMover {

  List<Movable> movables = new ArrayList();
  void draw(PGraphics g) {

    for (Movable m : movables) {
      m.draw(g);
    }
  }
}
