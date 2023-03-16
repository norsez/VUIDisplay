
class LaserPaint {
    int x = 0, y = 0;
    float yMod = 0, xMod = 0, alphaMod = 0, modRadius = 0;
    color pixel = C_PINK;
    color colorStroke = C_DEFAULT_FILL;
    ARect bound; 
    float brightness;
    float alphaFrame, dxAlphaFrame;
    LaserPaint(ARect bound) {
        this.bound = bound;
        this.dxAlphaFrame = 1.0/(frameRate * random(0.01, 1)) ;
        this.alphaFrame = random(0,1);
    }

    void draw(PGraphics g) {
        g.push();
        g.strokeWeight(1);
        g.stroke(colorStroke, alphaFrame * 100 + 100 * ampsum);
        g.noFill();
        g.ellipse(this.x + this.xMod, this.y + this.yMod, 1 + modRadius,1 + modRadius);
        g.pop();
        
        alphaFrame -= dxAlphaFrame;
        if(alphaFrame <=0) alphaFrame = 1;
    }

    String toString() {
        return "(" + x + "," + y + ")";
    }
}

class DisplayLaserPaint extends AbstractDisplay {
    PImage image;
    final int MAX_LASER = 5000;
    List<LaserPaint> lasers = new ArrayList();
    LFO lfoLaserWave;
    String filename;
    float averageBrightness;

    DisplayLaserPaint(ARect bound){
        super(bound);
        lfoLaserWave = new LFO(LFO.SHAPE_SINE, 0, 0.50/frameRate);
    }

    //black and white image. white is the laser trace path.
    void setImage(String filename){
        this.filename = filename;
        image = loadImage(filename);
        lasers = new ArrayList();
        image.loadPixels();

        List<Float>allBrightness = new ArrayList();

        //find white path
        for(int x=0; x < image.width; x++) {
            for(int y=0; y < image.height; y++) {
               color p = image.pixels[x+y*image.width];
               if (brightness(p) < 127) continue;
            
               LaserPaint lp = new LaserPaint(bound);
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
        lasers =  lasers.subList(0, min( lasers.size(), MAX_LASER));
        pdebug("laser points: " + lasers.size() +"\n" + lasers);
 //<>// //<>// //<>//
        float sum = 0;
        for(Float b: allBrightness) {
            sum += b;
        }
        averageBrightness = sum/allBrightness.size();
    } //<>//

    void draw(PGraphics g) {
        if (super.hidden) return;

        PGraphics localG = createGraphics(this.image.width, this.image.height); //<>//
        localG.beginDraw();
        //float _amp = ampsum * _modRadiusCtrlA;
        for(int i=0; i<lasers.size(); i++) {
            LaserPaint lp = lasers.get(i);
            lp.modRadius  = ampsum * _modRadiusCtrlA;
            lp.yMod = random(-_yModCtrlA,_yModCtrlA);
            lp.xMod = random(-_xModCtrlA,_xModCtrlA)  
             +  (lp.brightness > averageBrightness ? -1:1) * ampsum * _xBrightnessDisCtrlA; //<>//
            
            lp.alphaMod = -lfoLaserWave.currentValue * _modAlphaCtrlA;
            
            lp.draw(localG);
        }
        localG.endDraw();

        drawOn(localG, g, bound);
        lfoLaserWave.nextValue(); //<>//

        updateParams();
    }
    
    float _yModCtrlA = 0, _xModCtrlA = 0, _modRadiusCtrlA = 0
     , _modAlphaCtrlA = 0, _xBrightnessDisCtrlA = 0;

    void updateParams() {
        if (frameCount % APP_PARAM_UPDATE_RATE != 0) return;
        _yModCtrlA = mapCtrlA(1, 50);
        _xModCtrlA = mapCtrlA(1, 50);
        _modRadiusCtrlA = map(cvLinearToExp8( mapCtrlA(0,1)), 0, 1, 0, 25);
        _modAlphaCtrlA = mapCtrlA(1,150);
        _xBrightnessDisCtrlA = mapCtrlA(0, 100);
    }
    
    void bang() {
      this.setImage(this.filename);
    }
}
