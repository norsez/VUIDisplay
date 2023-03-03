class DisplayWave extends AbstractDisplay {
  
  final int MAX_INSTANCES = 200;
  final int ONE_INIT = 1;
  List<AlphaBall> balls;
 

  DisplayWave(ARect bound) {
    super(bound);
    balls = new ArrayList();
    controlA = -100;
    controlB = -100;
  }

  void draw(PGraphics g) {
    
    if (super.hidden) return;
    PGraphics lg = createGraphics(super.bound);
    lg.beginDraw();
    lg.background(0,50);
     balls.removeIf(b -> (b.dead));
    if (balls.size() >= MAX_INSTANCES) {
        balls = balls.subList(ONE_INIT, balls.size() - 1);
     }
    
    float bandwidth = lg.width / float(NUM_SAMPLES_WAVE);
    for(int i=0; i< NUM_SAMPLES_WAVE; i++){
      AlphaBall b = new AlphaBall(int(i * bandwidth), 
                                  (int)map(waveform.data[i], -1, 1, 0, lg.height)
                                  , g);
      b.velocity_secs_per_round = 0.01;
      b.radius = 1;
      b.maxRadius = 8; 
      b.alpha = 60;
      balls.add(b);
    }
    
    for(AlphaBall b: balls){
      b.draw(lg);
    }
    
    lg.endDraw();
    
    drawOn(lg, g, super.bound);
    
  }
}
