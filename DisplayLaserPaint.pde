
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

  void draw(PGraphics g) {
    g.push();
    g.strokeWeight(1);
    g.stroke(colorStroke, alphaFrame * 100 + 100 * ampsum);
    g.noFill();
    g.ellipse(this.x + this.xMod, this.y + this.yMod, 1 + modRadius, 1 + modRadius);
    g.pop();

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
        lp.colorStroke = colorFromMap();
        lp.brightness = brightness(p);
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
  }
}

class LaserImageSet { //<>//
  List<LaserImage> images;
  int imageIndex = 0;
  float currentFrame, dxFrameToSwitch;

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
      imageIndex = (imageIndex + 1) % images.size();
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
    List<LaserPaint> lasers = li.lasers;
    PGraphics localG = createGraphics(li.w, li.h); //<>//
    localG.beginDraw();
    //float _amp = ampsum * _modRadiusCtrlA;
    for (int i=0; i<lasers.size(); i++) {
      LaserPaint lp = lasers.get(i);
      lp.modRadius  = ampsum * _modRadiusCtrlA;
      lp.yMod = random(-_yModCtrlA, _yModCtrlA);
      lp.xMod = random(-_xModCtrlA, _xModCtrlA)
        +  (lp.brightness > li.averageBrightness ? -1:1) * ampsum * _xBrightnessDisCtrlA; //<>//

      lp.alphaMod = -lfoLaserWave.currentValue * _modAlphaCtrlA;

      lp.draw(localG);
    }
    localG.endDraw();

    drawOn(localG, g, bound);
    lfoLaserWave.nextValue(); //<>//
    imageSet.tick();
    updateParams();
  }

  float _yModCtrlA = 0, _xModCtrlA = 0, _modRadiusCtrlA = 0
    , _modAlphaCtrlA = 0, _xBrightnessDisCtrlA = 0;

  void updateParams() {
    if (frameCount % APP_PARAM_UPDATE_RATE != 0) return;
    _yModCtrlA = mapCtrlA(1, 50);
    _xModCtrlA = mapCtrlA(1, 50);
    _modRadiusCtrlA = map(cvLinearToExp8( mapCtrlA(0, 1)), 0, 1, 0, 25);
    _modAlphaCtrlA = mapCtrlA(1, 150);
    _xBrightnessDisCtrlA = mapCtrlA(0, 100);
  }

  void bang() {
    
  }
}
