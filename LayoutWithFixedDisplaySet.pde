
//extends LayoutAllInOut so that there's a fixed set of displays that shows by default
//with one display from the constructor to take turn
class LayoutWithFixedDisplaySet extends LayoutAllInOne {
  List<DisplayInterface> fixedDisplays;
  LayoutWithFixedDisplaySet(ARect bound, List<DisplayInterface> displays) {
    super(bound, displays);
    super.maxDisplays = 1;

    fixedDisplays = new ArrayList();
    fixedDisplays.add(new DisplayRulers(bound));
    fixedDisplays.add(new DisplayStarZoom(bound));
    fixedDisplays.add(new DisplaySourceCode(bound));
    fixedDisplays.add(new DisplayWalkingTiles(bound));
    int titleWidth = 250, titleHeight = 33, titleMargin = 30;
    ARect titleBound = new ARect(bound.width - titleWidth - titleMargin, bound.height - titleHeight - titleMargin, titleWidth, titleHeight);
    DisplayTitle dtitle = new DisplayTitle(bound, titleBound, "Norsez - Volume of the Ocean");


    layout = new LayoutAllInOne(bound, displays);
    fixedDisplays.add(dtitle);
  }

  void draw(PGraphics g) {
    super.draw(g);
    g.push();
    g.tint(255,200);
    for(DisplayInterface d: this.fixedDisplays) {
      d.draw(g);
    }
    g.pop();
  }
}
