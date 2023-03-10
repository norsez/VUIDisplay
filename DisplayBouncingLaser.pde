

class LaserTrail {
  
  float vx, vy, dx, dy, dxAmp, dyAmp;
  float x,y;
  float alpha = 120;
  boolean dead;
  float size = 3;
  float maxSizeAmp = 20;
  float vel_px_per_sec = 0.1;
  Easing eAlpha;
  
  
  LaserTrail(float vx, float vy, float x, float y) {
    this.vx = vx;
    this.vy = vy;
    this.x = x;
    this.y = y;
    eAlpha = new Easing();
    eAlpha.easing = random(0.1,0.5);
  }
  
  float _pxPerFrame;
  void setSpeed(float px_per_sec) {
    this.vel_px_per_sec = px_per_sec;
    _pxPerFrame = vel_px_per_sec /frameRate;
    this.calcDxDy();
  }
  
  void calcDxDy() {
    //pixel = k * width/frameRate
    dx = vx * _pxPerFrame;
    dy = vy * _pxPerFrame;
  }
  
  void addAmpSpeed(float n_temp_speed) {
    dxAmp = vx * map(n_temp_speed, 0,1,0,0.8) /frameRate;
    dyAmp = vy * map(n_temp_speed, 0,1,0,0.8) /frameRate;
  }
         
  void draw(PGraphics g) {
    
    g.noStroke();
    g.fill(colorFromMap(int(x),int(y), true), eAlpha.ease(alpha));
    g.strokeCap(ROUND);
    g.rectMode(CENTER);
    float s = size + cvLinearToExp8(ampsum) * maxSizeAmp;
    g.rect(x,y,s,s,5);
    
    
    this.calcDxDy();
    x = x + dx ;//+ dxAmp;
    y = y + dy ;// + dyAmp;
     
    calcDirection();
    updateParameters();
  }

  void updateParameters() {
    if(frameCount % APP_PARAM_UPDATE_RATE !=0) return;
    this.addAmpSpeed(ampsum);
  }
  
  void calcDirection() {
    if (x > g.width || x <=0 || y <=0 || y > g.height) {
      //recalc new direction
      vx = random(-1,1);
      vy = random(-1,1);
      this.setSpeed(this.vel_px_per_sec);
    }
  }
  
  void receiveMouseKeyInput() {
       this.maxSizeAmp = map(controlA, -100,100, this.size, 40);
  }
  
}


class DisplayBouncingLaser extends AbstractDisplay{
  int MAX_INSTANCES = 500;
  List<LaserTrail> trails;
  
  
  DisplayBouncingLaser(ARect bound) {
    super(bound);
    trails = new ArrayList();
    float w = bound.width;
    float h = bound.height;
    for(int i=0; i<100; i++){
      
      LaserTrail t = new LaserTrail(random(-1,1),random(-1,1),random(w*0.45,w*0.55),random(h*0.45,h*0.55));
      t.setSpeed(50);
      trails.add(t);
    }
  }
  
  
  void draw(PGraphics mainG) {
    
    if (super.hidden) return;
    
    if (trails.size() > MAX_INSTANCES) {
      trails = trails.subList(trails.size()  - MAX_INSTANCES, trails.size()-1);
    }
    
    if (mousePressed) {
      LaserTrail t = new LaserTrail(random(-1,1),random(-1,1),mouseX,mouseY);
      t.setSpeed(0.1);
      t.size = 5;
      t.maxSizeAmp = 10;
      trails.add(t);
    }
    
    PGraphics g = createGraphics(int(mainG.width), mainG.height);
    g.beginDraw();
    //g.background(0,100);
    for(LaserTrail t: trails) {
      t.setSpeed(_speedCtrlA);
      t.maxSizeAmp = _maxSizeCtrlA;
      t.draw(g);
    }
    g.endDraw();
    
    //draw mirror
    mainG.push();  
    mainG.image(g, 0, 0);
    mainG.scale(1,-1);
    mainG.translate(mainG.width * 0.5, 0);
    mainG.image(g, 0, 0);
    mainG.pop();
    
    updateParameters();
    
  }

  float _speedCtrlA, _maxSizeCtrlA;

  void updateParameters() {
    if (frameCount % APP_PARAM_UPDATE_RATE != 0) return;

    _speedCtrlA = mapCtrlA(15,500);
    _maxSizeCtrlA = mapCtrlA(10,150);
  }
  
  
}
