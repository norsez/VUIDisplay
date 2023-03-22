
abstract class Movable {
  int startX, startY;
  int endX, endY;
  float curFrames, dxFrames;
  PGraphics gToMove;
  boolean done = false;
  void setDuration(float secs) {
    curFrames = secs * frameRate;
    dxFrames = 1.0/curFrames;
  }

  void draw(PGraphics g) {
    float nowX = endX, nowY = endY;
    if (!done) {
      float curRatio =  1.0 -( curFrames * dxFrames );
      nowX = lerp(startX, endX, curRatio);
      nowY = lerp(startY, endY, curRatio);
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
