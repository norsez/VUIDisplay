
class AlphaBall {
  float baseX, baseY = 0;
  float radius = 15;
  float velocity_secs_per_round = 1;
  float deltaDistance = 0;
  boolean dead = false;
  float maxRadius = 25;
  float alpha = 100;
  
  AlphaBall(float initX, float initY, PGraphics g) {
    this.baseX = initX;
    this.baseY = initY;
    this.radius = 25 * ampsum * 50 ;
    this.velocity_secs_per_round = random(3, 25);
    this.deltaDistance = (g.width - baseX)/(this.velocity_secs_per_round * frameRate);
  }

  void draw(PGraphics g) {

    if (dead)
      return;

    //g.stroke(color(0,200,0,10));
    g.stroke(colorFromMap(int(baseX), int(baseY), true), alpha);
    g.fill(0, 0);
    g.ellipse(baseX, baseY, this.radius, this.radius);

    this.baseX += this.deltaDistance;
    if (this.baseX > g.width) {
      this.baseX = 0;
    }

    this.radius = this.radius * 1.01 + (ampsum* 1.0015);
    if (this.radius > maxRadius) {
      dead = true;
    }
  }
}
