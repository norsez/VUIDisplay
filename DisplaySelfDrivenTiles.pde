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
    
    localG.blendMode(ADD);
    topLine.draw(localG);
    bottomLine.draw(localG);
    localG.endDraw();
    //g.tint(255,200);
    g.image(localG, this.bound.originX, this.bound.originY);
  }
}
