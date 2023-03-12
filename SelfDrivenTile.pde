class AutoDrivenTile {
  final int UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3;
  ARect tileRect, boundingBox;
  int direction = 0;
  float wait;
  float dx = 0;
  final float waitTime = 0.05 * frameRate; //seconds
  final float maxDirectionFrame = 2 * frameRate;
  float walkTime = 0;
  float topAmpSpeed = 100;
  float topAmpSize = 10;
  int baseAlpha = 35;
  String someId = "?";

  AutoDrivenTile(ARect tileRect, ARect boundingBox) {
    this.tileRect = tileRect;
    this.boundingBox = boundingBox;
    this.baseAlpha = (int) random(66, 176);
    direction = int(random(0, 3));
    
    int value = int(random(0,1) * 10000);
    someId = Integer.toHexString(value);
  }

  void setSpeed(float speed_px_per_sec) {
    dx = speed_px_per_sec / frameRate;
  }

  void draw(PGraphics g) {
    g.noStroke();
    color tileColor = colorFromMap(int(this.tileRect.originX * 0.5),
      int(this.tileRect.originY * 0.5),
      this.tileRect);
    g.stroke(tileColor, 100);
    g.strokeWeight(0.4);
    g.fill(tileColor,  mapCurve(ampsum,2) * this.baseAlpha);

    // if not wait, is it walkable
    // yes, do it
    // no wait and plan next dir
    if (wait > 0) {
      wait = wait - 1;
    } else {
      calcWalk();
    }

    g.rect(tileRect.originX, tileRect.originY, tileRect.width + ampsum * topAmpSize, tileRect.height + ampsum * topAmpSize, 4);
    printDebug(g);
    g.textSize(6);
    g.fill(tileColor,200);
    
    g.text(someId, 2 + tileRect.originX, 2 + tileRect.originY + 6);
  }

  void printDebug(PGraphics g) {
    if (!DEBUG) return;
    int margin = 10;
    int x = (int)tileRect.originX;
    int y = int(tileRect.originY+ tileRect.height + 2);

    color c = wait > 0? color(255, 0, 0): color(255);


    pdebug("d: " + direction, x, y, g, c);
    y += margin;

    pdebug("wait: " + wait, x, y, g, c);
    y+=margin;

    pdebug("dx: " + dx, x, y, g, c);
    y+=margin;

    pdebug("wt: " + walkTime, x, y, g, c);
  }
  
  void calcWalk() {
    boolean mustWait = false;
    if (direction == UP || direction == DOWN) {
      mustWait = (tileRect.originY + dx < 0 || tileRect.originY + tileRect.height + dx > boundingBox.height);
    } else {
      mustWait = (tileRect.originX + dx < 0 || tileRect.originX + tileRect.width + dx > boundingBox.width);
    }
    

    if (mustWait) {
      wait = waitTime;
      newStrategy();
    } else {
      if (direction == UP || direction == DOWN) {
        tileRect.originY = tileRect.originY + dx;
      } else {
        tileRect.originX = tileRect.originX + dx;
      }
      walkTime += 1;

      if (walkTime >= maxDirectionFrame) {
        newStrategy();
      }
    }
  }
  
  void newStrategy() {
    
      //plan next move...
      direction = newDirection(direction);
      if (direction == DOWN || direction == RIGHT) {
        dx = abs(dx);
      } else {
        dx = -abs(dx);
      }
      walkTime = 0;
  }

  int newDirection(int oldDir) {
   List<Integer> l = new ArrayList();
   for (int i=0; i<4; i++){
     if (i != oldDir){
       l.add(i);
     }
   }
   Collections.shuffle(l);
   return l.get(0);
  }
}

class BlinkingSelfDrivenTile extends AutoDrivenTile {
  LFO lfoBlink;


  BlinkingSelfDrivenTile(ARect tileRect, ARect bound) {
    super(tileRect, bound);
    lfoBlink = new LFO(LFO.SHAPE_SINE, 0,  (1.0/4.0)/frameRate);
  }

  void draw(PGraphics g) {
    g.push();
    g.tint(255, 255 * lfoBlink.nextValue());
    super.draw(g);
    g.pop();
  }
  
}