
//image should be 480x??? only white color is painted. brigtness is alpha.
class LaserPaint {
  int x = 0, y = 0;
  float yMod = 0, xMod = 0, alphaMod = 0, modRadius = 0;
  color pixel = C_PINK;
  color colorStroke = C_DEFAULT_FILL;

  float brightness;
  float alphaFrame, dxAlphaFrame;
  LaserPaint() {
    this.dxAlphaFrame = 1.0/(frameRate * random(0.01, 1)) ;
    this.alphaFrame = random(0, 1);
  }

  void draw(PGraphics g, float scaling, float originX, float originY) {
    g.push();
    g.strokeWeight(1);
    g.stroke(colorStroke, alphaFrame * 100 + 100 * ampsum);
    g.noFill();
    g.ellipse((this.x + this.xMod) * scaling, (this.y + this.yMod) * scaling, 1 + modRadius, 1 + modRadius);
    g.pop(); //<>//

    alphaFrame -= dxAlphaFrame;
    if (alphaFrame <=0) alphaFrame = 1;
  }

  String toString() {
    return "(" + x + "," + y + ")";
  }
}


class LaserImage {
  float averageBrightness;
  List<LaserPaint> lasers = new ArrayList();
  int w,h;

  float drawScaling = 1;
  float drawOriginX = 0, drawOriginY = 0;

  void loadImageWithName(String filename, int max_points) {
    PImage image = loadImage(filename);
    w = image.width;
    h = image.height;
    lasers = new ArrayList();
    image.loadPixels();

    List<Float>allBrightness = new ArrayList();

    //find white path
    for (int x=0; x < image.width; x++) {
      for (int y=0; y < image.height; y++) {
        color p = image.pixels[x+y*image.width];
        if (brightness(p) < 127) continue;

        LaserPaint lp = new LaserPaint();
        lp.pixel = p;
        lp.brightness = brightness(p);
        lp.colorStroke = color(red(C_DEFAULT_FILL), green(C_DEFAULT_FILL), blue(C_DEFAULT_FILL), 255 * cvLinearToExp8( lp.brightness/255.0));
        allBrightness.add(lp.brightness);
        lp.x = x;
        lp.y = y;
        lasers.add(lp);
      }
    }

    Collections.shuffle(lasers);
    lasers =  lasers.subList(0, min( lasers.size(), max_points));

    float sum = 0;
    for (Float b : allBrightness) {
      sum += b;
    }
    averageBrightness = sum/allBrightness.size();

    drawScaling = random(0.5,5);
  }

  void draw(PGraphics g) {
    for(LaserPaint lp: this.lasers) {
      lp.draw(g, drawScaling, drawOriginX, drawOriginY);
    }
  }
}

class LaserImageSet { //<>// //<>// //<>//
  List<LaserImage> images;
  int imageIndex = 0;
  float currentFrame, dxFrameToSwitch;

  void nextImage() {
    imageIndex = (imageIndex + 1) % images.size();
    images.get(imageIndex).drawScaling = random(1,2);
    // images.get(imageIndex).drawOriginX = random(0, width* 0.5);
    // images.get(imageIndex).drawOriginY = random(0, height *  0.5);
  }

  LaserImageSet() {
    this.setSecondstoSwitch(3);
  }

  void setSecondstoSwitch(float seconds) {
    currentFrame = 1;
    dxFrameToSwitch = 1.0/(seconds * frameRate);
  }

  void tick() {
    currentFrame -= dxFrameToSwitch;
    if (currentFrame <= 0) {
      currentFrame = 1;
      nextImage();
    }
  }

  LaserImage currentImage() {
    return images.get(imageIndex);
  }

  void loadImages(String [] filenames, int maxPoints) {
    images = new ArrayList();
    for (String f : filenames) {
      LaserImage li = new LaserImage();
      li.loadImageWithName(f, maxPoints);
      images.add(li);
    }
  }
}

class DisplayLaserPaint extends AbstractDisplay {
  LaserImageSet imageSet;
  final int MAX_LASER = 5000;
  LFO lfoLaserWave;
  

  DisplayLaserPaint(ARect bound, String [] imageFilenames) {
    super(bound);
    
    lfoLaserWave = new LFO(LFO.SHAPE_SINE, 0, 0.50/frameRate);
    imageSet = new LaserImageSet();
    imageSet.loadImages(imageFilenames, MAX_LASER);
  }



  void draw(PGraphics g) {
    if (super.hidden) return;
    
    LaserImage li = imageSet.currentImage();
   
    PGraphics localG = createGraphics(bound);
    localG.beginDraw();
    li.draw(localG);
    localG.endDraw();

    drawOn(localG, g, bound);
    lfoLaserWave.nextValue();
    imageSet.tick();
    updateParams();
  }

  float _yModCtrlA = 0, _xModCtrlA = 0, _modRadiusCtrlA = 0
    , _modAlphaCtrlA = 0, _xBrightnessDisCtrlA = 0;

  void updateParams() {
    if (frameCount % APP_PARAM_UPDATE_RATE != 0) return;
    _yModCtrlA = mapCtrlA(1, 50);
    _xModCtrlA = mapCtrlA(0, 1);
    _modRadiusCtrlA = map(cvLinearToExp8( mapCtrlA(0, 1)), 0, 1, 0, 25);
    _modAlphaCtrlA = mapCtrlA(1, 150);
    _xBrightnessDisCtrlA = mapCtrlA(0, 100);
  }

  void bang() {
    imageSet.nextImage();
  }
}
