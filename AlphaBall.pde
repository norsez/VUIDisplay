
class AlphaBall {
  float baseX, baseY = 0;
  float radius = 15;
  float vel_px_per_sec = 10;
  float deltaDistance = 0;
  boolean dead = false;
  float maxRadius = 25;
  float alpha = 45;
  float vel_radius_px_per_sec = 10;
  float deltaRadius = 0;
  float radiusY = 0;
  
  AlphaBall(float initX, float initY, ARect g) {
    this.baseX = initX;
    this.baseY = initY;
    this.radius = 25 * ampsum * 50 ;
    this.vel_px_per_sec = random(3, 25);
    
  }

  void draw(PGraphics g) {

    if (dead)
      return;
      
    this.deltaDistance = this.vel_px_per_sec/frameRate;
    this.deltaRadius = vel_radius_px_per_sec/frameRate;

    //g.stroke(color(0,200,0,10));
    alpha = 80 + alpha  * radius/maxRadius;
    g.stroke(colorFromMap(int(baseX), int(baseY), true), alpha + 50 * ampsum);
    g.fill(0, 0);
    g.ellipse(baseX, baseY, this.radius, this.radius + this.radiusY);

    this.baseX += this.deltaDistance;
    if (this.baseX > g.width) {
      this.dead = true;
    }

    this.radius = this.radius + deltaRadius;
    if (this.radius > maxRadius) {
      dead = true;
    }
  }
}
