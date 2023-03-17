
//extends LayoutAllInOut so that there's a fixed set of displays that shows by default
//with one display from the constructor to take turn
class LayoutWithFixedDisplaySet extends LayoutAllInOne {
  List<DisplayInterface> fixedDisplays;
  LFO lfoCtrlA1, lfoCtrlA2;

  LayoutWithFixedDisplaySet(ARect bound, List<DisplayInterface> displays) {
    super(bound, displays);
    super.maxDisplays = 1;
    super.useFullAlphaLayerMode = false;

    lfoCtrlA1 = new LFO(LFO.SHAPE_SINE, random(0,1), 0.26/ frameRate);
    lfoCtrlA2 = new LFO(LFO.SHAPE_SINE, random(0,1), 4.6/ frameRate);

    fixedDisplays = new ArrayList();
    fixedDisplays.add(new DisplayGridMove(bound));
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
    lfoCtrlA1.nextValue();
    lfoCtrlA2.nextValue();
    
    updateParameters();
  }

  void updateParameters () {
    if(frameCount % APP_PARAM_UPDATE_RATE != 0) return;

    controlA = abs((lfoCtrlA1.currentValue + lfoCtrlA2.currentValue) * 4);
  }

  void bang() {
    super.bang();

    for(DisplayInterface d: fixedDisplays) {
      d.bang();
    }

    super.fullAlphaLayer = 0;
  }
}
