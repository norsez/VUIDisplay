class StarWithPath {
  ARect bound;
  ARect path;
  float velPxPerSec, distance;
  float maxRadius;
  float startRadius;
  float alpha;
  color myColor;
  float dx = 0, dy = 0;
  boolean dead;
  
  StarWithPath(ARect bound, float velPxPerSec){
    this.bound = bound;
    path = new ARect();
    path.originX  = bound.width * 0.5;
    path.originY  = bound.height * 0.5;
    path.width = random(0,bound.width);
    path.height = random(0,bound.height);
    this.maxRadius = random (1.5, 15);
    this.alpha = random(40,190);
    this.velPxPerSec = velPxPerSec;
    this.distance =  velPxPerSec / frameRate;
    this.myColor = colorFromMap();
    
  }

  void draw(PGraphics g){
    
    if (dead) return;
    
    g.fill(this.myColor, 200);
    g.noStroke();

    float r = 0.5 + lerp(startRadius, maxRadius, dx);
    float x = lerp(path.originX, path.width, dx);
    float y = lerp(path.originY, path.height, dy);
    g.ellipse(x,y,
      
      r, r
      );

    dx += distance;
    dy += distance;
    
    dead = dx > 1 && dy > 1;
  }

}

class DisplayStarZoom extends AbstractDisplay {
  
  List<StarWithPath> stars;
  final int MAX_STARS = 100;
  float newStarEveryNFrames;
  float NUM_STARS_PER_N_FRAMES = 25;
  float curFrame;
  PGraphics buffer;
  
  DisplayStarZoom(ARect b) {
    super(b);
    newStarEveryNFrames = 2 * frameRate;
    stars = new ArrayList();
    createStars();
  }

  void createStars() {
    
    stars.removeIf(s ->(s.dead));
    if (stars.size() > MAX_STARS ){
      stars = stars.subList(MAX_STARS, stars.size()-1);
    }

    for(int i=0; i < NUM_STARS_PER_N_FRAMES; i++) {
      StarWithPath s = new StarWithPath(bound, random(0.0001, 1));
      stars.add(s);
    }
  }
  
  void draw(PGraphics g) {
    if (super.hidden) return;
    buffer = createGraphics(bound);

    if (curFrame >= newStarEveryNFrames) {
      curFrame = 0;
      createStars();
    }
    
    buffer.beginDraw();

    for(StarWithPath s: stars){
      s.draw(g);
    }
    buffer.endDraw();

    
    drawOn(buffer, g, bound);

    curFrame++;
  }
  
}
