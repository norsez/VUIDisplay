class DisplayStarZoom extends AbstractDisplay {
  float MAX_STARS_LAYERS = 10;
  PGraphics buffer;
  
  float width_per_layer;
  float height_per_layer;
  float maxScaling = 2;
  float currentScaling = 1;
  float scalingDx = 1;
  float speed_max_scaling_in_sec = 8.0;
  
  float minModA,maxModA;
  
  DisplayStarZoom(ARect b) {
    super(b);
    buffer = createGraphics(b);
    drawStars();
    width_per_layer =  b.width/MAX_STARS_LAYERS;
    height_per_layer = b.height/MAX_STARS_LAYERS;
    scalingDx = 0.1 / ( speed_max_scaling_in_sec * frameRate );
    minModA = 0.01/frameRate;
    maxModA = 1 / frameRate;
  }
  
  void drawStars() {
    buffer = createGraphics(bound);
    buffer.beginDraw();
    buffer.background(0);
    int maxStars = int( random(80, 100) ); //<>//
    for (int i=0; i < maxStars; i++){
      buffer.noStroke();
      buffer.fill(colorFromMap(), random(1,190));
      float size = random (0.01, 2.8) + mapCtrl(controlA, 0.1, 2);
      buffer.ellipse(random(0,bound.width),random(0,bound.height),size,size);
    }
    buffer.endDraw();
  }

  
  void draw(PGraphics g) {
    if (super.hidden) return;
    buffer.beginDraw();
    buffer.background(0, 1);
    buffer.imageMode(CENTER);
    buffer.scale(currentScaling, currentScaling);
    buffer.image( buffer, buffer.width * 0.5/currentScaling, buffer.height * 0.5/currentScaling);
 
    buffer.endDraw();
    currentScaling += scalingDx + mapCtrl(controlA, minModA, maxModA);
    
    //reach max
    if (currentScaling > maxScaling) {
      currentScaling = 1;
      drawStars();
      debug("new stars", C_RED);
    }
    
    drawOn(buffer, g, bound);
  }
  
}
