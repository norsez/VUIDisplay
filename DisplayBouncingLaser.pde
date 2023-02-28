

class LaserTrail {
  
  float vx, vy, dx, dy, dxAmp, dyAmp;
  float x,y;
  float alpha = 120;
  boolean dead;
  float size = 3;
  float maxSizeAmp = 20;
  float speed = 0.1;
  
  
  LaserTrail(float vx, float vy, float x, float y) {
    this.vx = vx;
    this.vy = vy;
    this.x = x;
    this.y = y;
  }
  
  void setSpeed(float n_speed) {
    this.speed = n_speed;
    this.calcDxDy();
  }
  
  void calcDxDy() {
    //pixel = k * width/frameRate
    dx = vx * map(mapCurve(speed,9), 0,1,0.001,1) * width/frameRate;
    dy = vy * map(mapCurve(speed,9), 0,1,0.001,1) * height/frameRate;
  }
  
  void addAmpSpeed(float n_temp_speed) {
    dxAmp = vx * map(n_temp_speed, 0,1,0,0.8) * width/frameRate;
    dyAmp = vy * map(n_temp_speed, 0,1,0,0.8) * height/frameRate;
  }
         
  void draw(PGraphics g) {
    
    g.noStroke();
    g.fill(colorFromMap(int(x),int(y), true), alpha);
    g.strokeCap(ROUND);
    g.rectMode(CENTER);
    float s = size + (mapCurve(ampsum, 8) * maxSizeAmp);
    g.rect(x,y,s,s);
    
    this.addAmpSpeed(ampsum);
    this.calcDxDy();
    x = x + dx + dxAmp;
    y = y + dy + dyAmp;
     
    calcDirection();
    
    receiveMouseKeyInput();
  }
  
  void calcDirection() {
    if (x > g.width || x <=0 || y <=0 || y > g.height) {
      //recalc new direction
      vx = random(-1,1);
      vy = random(-1,1);
      this.setSpeed(this.speed);
    }
  }
  
  void receiveMouseKeyInput() {
       this.maxSizeAmp = map(controlA, -100,100, this.size, 40);
  }
  
}


class DisplayBouncingLaser extends AbstractDisplay{
  int MAX_INSTANCES = 500;
  List<LaserTrail> trails;
  PGraphics g;
  
  DisplayBouncingLaser(ARect bound) {
    super(bound);
    trails = new ArrayList();
    float w = bound.width;
    float h = bound.height;
    for(int i=0; i<100; i++){
      
      LaserTrail t = new LaserTrail(random(-1,1),random(-1,1),random(w*0.45,w*0.55),random(h*0.45,h*0.55));
      t.setSpeed(0.01);
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
      t.setSpeed(0.01);
      t.size = 5;
      t.maxSizeAmp = 10;
      trails.add(t);
    }
    
    g = createGraphics(int(mainG.width), mainG.height);
    g.beginDraw();
    g.background(0, 15);
    for(LaserTrail t: trails) {
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
    
    
  }
  
  
}
