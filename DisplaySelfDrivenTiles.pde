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

  AutoDrivenTile(ARect tileRect, ARect boundingBox) {
    this.tileRect = tileRect;
    this.boundingBox = boundingBox;
    this.baseAlpha = (int) random(12, 76);
    direction = int(random(0, 3));
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
  }

  void printDebug(PGraphics g) {
    if (!DEBUG) return;
    int margin = 10;
    int x = (int)tileRect.originX;
    int y = int(tileRect.originY+ tileRect.height + 2);

    color c = wait > 0? color(255, 0, 0): color(255);


    debug("d: " + direction, x, y, g, c);
    y += margin;

    debug("wait: " + wait, x, y, g, c);
    y+=margin;

    debug("dx: " + dx, x, y, g, c);
    y+=margin;

    debug("wt: " + walkTime, x, y, g, c);
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

class PulseLine {
  
  List<AutoDrivenTile> tiles;
  final int numTiles = 15;
  ARect bound;
  
  //origin x, y is the x,y to draw in parent Graphics
  PulseLine(ARect bound, int numTiles) {
    this.bound = bound;
    tiles = new ArrayList();
    
    for (int i=0; i< numTiles; i++) {
      float w = random(5,bound.width * 0.7);
      float h = random(5,bound.height * 0.8);
      float x = random(0, bound.width - w);
      float y = random(0, bound.height - h);
      ARect tileRect = new ARect(x,y,w,h);
      AutoDrivenTile t = new AutoDrivenTile(tileRect,this.bound);
      t.setSpeed(random(10,50));
      tiles.add(t);
    }
  }
  
  void draw(PGraphics g) {
    PGraphics localG = createGraphics(this.bound);
    localG.beginDraw();
    localG.background(0,20);
    for (AutoDrivenTile t: tiles) {
      t.draw(localG);
    }
    localG.endDraw();
    
    g.image(localG, this.bound.originX, this.bound.originY);
  }
  
}

class BottomLine {
  List<AutoDrivenTile> tiles = new ArrayList();
  ARect bound;
  BottomLine(ARect bound, int numTiles){
    this.bound = bound;
    for (int i=0; i< numTiles; i++) {
      ARect r = new ARect(this.bound.width * 0.5 ,0, mapCurve( float(i)/numTiles, 0.95) * 36, random(4, this.bound.height*.6));
      AutoDrivenTile t = new AutoDrivenTile(r, this.bound);
      t.setSpeed(random(25,100));
      tiles.add(t);
    }
  }
  
  void draw(PGraphics g) {
    PGraphics lg = createGraphics(this.bound);
    lg.beginDraw();
    for (AutoDrivenTile t: tiles) {
      t.draw(lg);
    }
    lg.endDraw();
    
    g.image(lg, this.bound.originX, this.bound.originY);
  }
}


class DisplayFFTPulse extends AbstractDisplay {
  PulseLine topLine;
  BottomLine bottomLine;
  DisplayFFTPulse(ARect bound) {
    super(bound);
    
    ARect topRect = new ARect(10,10,bound.width-20, bound.height * 0.1);
    topLine = new PulseLine(topRect, 8);
    ARect bottomRect = new ARect(10, 
                                 bound.height - (bound.height * 0.025) - 10,
                                 bound.width-20, 
                                 bound.height * 0.025);
    bottomLine = new BottomLine(bottomRect, 8);
  }

  void draw(PGraphics g) {
    if (super.hidden) return;
    
    PGraphics localG = createGraphics(this.bound);
    localG.beginDraw();
    localG.background(0,15);
    localG.blendMode(ADD);
    topLine.draw(localG);
    bottomLine.draw(localG);
    localG.endDraw();
    g.tint(255,200);
    g.image(localG, this.bound.originX, this.bound.originY);
  }
}
