class LayoutAllInOne extends AbstractLayout {
  
  LayoutAllInOne(ARect bound, List<DisplayInterface> dis) {
    super(bound,dis);
    
  }
  
  void draw(PGraphics g) {
    PGraphics lg = createGraphics(bound);
    lg.beginDraw();
    for(DisplayInterface d: displays){
      d.draw(g);
    }
    lg.endDraw();
    g.image(lg,bound.originX,bound.originY,bound.width, bound.height);
  }
  
}
