class DisplayWave extends AbstractDisplay {
  
  final int MAX_INSTANCES = 200;
  final int ONE_INIT = 1;
  List<AlphaBall> balls;
  PGraphics lg;

  float _maxRadius, _radiusY;
  DisplayWave(ARect bound) {
    super(bound);
    balls = new ArrayList();
  }

  void draw(PGraphics g) {
    
    if (super.hidden) return;
    lg = createGraphics(super.bound);
    lg.beginDraw();
    
     balls.removeIf(b -> (b.dead));
    if (balls.size() >= MAX_INSTANCES) {
        balls = new ArrayList();
    }
    
    float bandwidth = lg.width / float(NUM_SAMPLES_WAVE);
    for(int i=0; i< NUM_SAMPLES_WAVE; i++){
      AlphaBall b = new AlphaBall(int(i * bandwidth), 
                                  (int)map(waveform.data[i], -1, 1, 0.3 * height, lg.height * 0.7)
                                  , bound);
      b.vel_px_per_sec = 0.01;
      b.radius = 2;
      b.maxRadius = _maxRadius; 
      b.radiusY = _radiusY * b.radius ;
      b.alpha = 190 +  random(2,40);
      balls.add(b);
    }
    
    for(AlphaBall b: balls){
      b.draw(lg);
    }
    
    lg.endDraw();
    
    drawOn(lg, g, super.bound);
    updateParams();
  }

  void updateParams() {
    if(frameCount % APP_PARAM_UPDATE_RATE != 0) return;
    _maxRadius = 2 + 8 * mapCtrlA(0,1);
    _radiusY =  mapCtrlA(1,8);

  }
}
