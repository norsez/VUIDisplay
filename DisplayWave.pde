class DisplayWave extends AbstractDisplay {
  
  final int MAX_INSTANCES = 200;
  final int ONE_INIT = 1;
  List<AlphaBall> balls;
 

  DisplayWave(ARect bound) {
    super(bound);
    balls = new ArrayList();
  }

  void draw(PGraphics g) {
    
    if (super.hidden) return;
    PGraphics lg = createGraphics(super.bound);
    lg.beginDraw();
    
     balls.removeIf(b -> (b.dead));
    if (balls.size() >= MAX_INSTANCES) {
        balls = balls.subList(0, balls.size() - 1);
     }
    
    float bandwidth = lg.width / float(NUM_SAMPLES_WAVE);
    for(int i=0; i< NUM_SAMPLES_WAVE; i++){
      AlphaBall b = new AlphaBall(int(i * bandwidth), 
                                  (int)map(waveform.data[i], -1, 1, 0.3 * height, lg.height * 0.7)
                                  , bound);
      b.vel_px_per_sec = 0.01;
      b.radius = 2;
      b.maxRadius = 8 * mapCtrlA(0,1); 
      b.radiusY = b.radius * mapCtrlA(1,8);
      b.alpha = 190 +  random(2,40);
      balls.add(b);
    }
    
    for(AlphaBall b: balls){
      b.draw(lg);
    }
    
    lg.endDraw();
    
    drawOn(lg, g, super.bound);
    
  }
}
