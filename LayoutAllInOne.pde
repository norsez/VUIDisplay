class LayoutAllInOne extends AbstractLayout {
  int fullAlphaLayer = 0;
  boolean useFullAlphaLayerMode = true;
  
  //spotlight: one display at full opacity, the rest dimmed. the focused index turns
  //round-robin every spotlightMsec and hands over with a short crossfade so the change
  //reads as a cue rather than a glitch.
  float dimAlpha       = 102; //40% of 255 - the non-focused displays
  float spotlightMsec  = 3000;
  float handFadeMsec   = 500;
  float lastSwitchMsec = 0;
  int   prevAlphaLayer = -1;
  
  LayoutAllInOne(ARect bound, List<DisplayInterface> dis) {
    super(bound,dis);
    
    //start settled rather than mid-fade, so display 1 is at full opacity from frame one
    lastSwitchMsec = millis() - handFadeMsec;
  }
  
  //the alpha this display draws at right now
  float alphaFor(int i, float handT) {
    if (!useFullAlphaLayerMode) return 255;
    if (i == fullAlphaLayer)  return lerp(dimAlpha, 255, handT);
    if (i == prevAlphaLayer) return lerp(255, dimAlpha, handT);
    return dimAlpha;
  }
  
  void draw(PGraphics g) {
    
    if (super.isAuto && millis() - lastSwitchMsec >= spotlightMsec) {
      advanceSpotlight();
    }
    float handT = constrain((millis() - lastSwitchMsec) / handFadeMsec, 0, 1);
    
    PGraphics lg = createGraphics(bound);
    lg.beginDraw();
    lg.background(0);
    
    lg.push();
    for(int i=0; i<displays.size(); i++){
      DisplayInterface d = displays.get(i);
      
      float a = alphaFor(i, handT);
      if (a >= 255) lg.noTint(); else lg.tint(255, a);
      d.draw(lg);
      
    }
    lg.pop();
    lg.endDraw();
    
    g.image(lg,bound.originX,bound.originY,bound.width, bound.height);
    
  }
  
  //moves the focus to the next display that isn't hidden, wrapping round
  void advanceSpotlight() {
    if (displays.isEmpty()) return;
    
    prevAlphaLayer = fullAlphaLayer;
    do {
      fullAlphaLayer = (fullAlphaLayer + 1) % displays.size();
    } while (fullAlphaLayer != prevAlphaLayer && displays.get(fullAlphaLayer).isHidden());
    
    lastSwitchMsec = millis();
    println("spotlight: display " + (fullAlphaLayer + 1));
  }
  
  void resetSpotlight() {
    fullAlphaLayer = 0;
    prevAlphaLayer = -1;
    lastSwitchMsec = millis() - handFadeMsec;
  }
  
  void toggleAuto(){
    super.toggleAuto();
    
    //settled, so pausing or resuming never flashes every display dim
    lastSwitchMsec = millis() - handFadeMsec;
  }
}