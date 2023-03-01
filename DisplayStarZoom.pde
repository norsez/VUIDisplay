class DisplayStarZoom extends AbstractDisplay {
  float MAX_STARS_LAYERS = 10;
  PGraphics buffer;
  
  float width_per_layer;
  float height_per_layer;
  float maxScaling = 2;
  float currentScaling = 1;
  float scalingDx = 1;
  float speed_max_scaling_in_sec = 8.0;
  
  DisplayStarZoom(ARect b) {
    super(b);
    buffer = createGraphics(b);
    drawStars();
    width_per_layer =  b.width/MAX_STARS_LAYERS;
    height_per_layer = b.height/MAX_STARS_LAYERS;
    scalingDx = 1 / ( speed_max_scaling_in_sec * frameRate );
  }
  
  void drawStars() {
    buffer.beginDraw();
    buffer.background(0, 25);
    int maxStars = int( random(80, 250) );
    for (int i=0; i < maxStars; i++){
      buffer.noStroke();
      buffer.fill(colorFromMap(), random(50,100));
      float size = random (0.01, 2.8);
      buffer.ellipse(random(0,buffer.width),random(0,buffer.height),size,size);
    }
    buffer.endDraw();
  }
  
  void setSpeed(float px_per_second) {
  }
  
  
  void draw(PGraphics g) {
    if (super.hidden) return;
    buffer.beginDraw();
    buffer.background(0, 25);
    buffer.imageMode(CENTER);
    buffer.scale(currentScaling, currentScaling);
    buffer.image( buffer, buffer.width * 0.5/currentScaling, buffer.height * 0.5/currentScaling);
 
    buffer.endDraw();
    currentScaling += scalingDx;
    
    //reach max
    if (currentScaling > maxScaling) {
      currentScaling = 1;
      drawStars();
    }
    
    drawOn(buffer, g, bound, 100);
  }
  
}
