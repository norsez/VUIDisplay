
class Ruler {

    color C_TICK = color(110,175,132);
    PGraphics gRuler;
    PGraphics gPointer;

    ARect bound;
    float rulerHeight;
    
    LFO lfoRuler1, lfoRuler2;
    float speedRuler1;
    float secsToChangeSpeed;
    
    Ruler(ARect bound, float rulerHeight){
        this.bound = bound;
        this.rulerHeight = rulerHeight;
        secsToChangeSpeed = 3 * frameRate;
        
        prepareGraphics();
    }

    void prepareGraphics() {
        gRuler = createGraphics(int(bound.width * 2), (int) rulerHeight);
        gPointer = createGraphics(18,  (int)rulerHeight);

        speedRuler1 = random(1/40.0, 1/15.0)/frameRate;
        lfoRuler1 = new LFO(LFO.SHAPE_SINE, random(0,1), speedRuler1);
        lfoRuler2  = new LFO(LFO.SHAPE_SINE, random(0,1), random(1/12.0, 1/2)/frameRate);
        
        gRuler.beginDraw();
        int numTicks = (int)random(95, 395);
        int numBigTicks = (int)random(6, 67);
        int bigTickPer  = int(numTicks / float(numBigTicks));
        float tickHeight = random(0.2, 0.6) * rulerHeight;
        float bigTickHeight = random(0.6,0.75) * rulerHeight;
        color tickColor = color(C_TICK);
        color bigTickColor = color(C_TICK);
        float tickMargin = float(gRuler.width) / numTicks;

        gRuler.push();
        gRuler.textFont(FONT_6);
        for(int i=0; i <numTicks; i++) {
            boolean isBigTick = i % bigTickPer == 0;
            gRuler.noFill();
            gRuler.stroke(isBigTick?bigTickColor:tickColor, 100 + random(1,50));
            gRuler.strokeWeight(isBigTick? 1.7: 0.5 + random(-0.1,0.1));
            gRuler.line(0,0,0,isBigTick?bigTickHeight:tickHeight);
            if (isBigTick) {
              gRuler.fill(C_TICK, random(120,190));
              int strLen = (int)map(numBigTicks,6,67,6,2);
              gRuler.text(randomString(strLen), -strLen * 0.5, rulerHeight - 7);
            }
            gRuler.translate(tickMargin, 0);
            
            
        }
        gRuler.pop();
        gRuler.endDraw();

    }

    float _drawSliding(){
        float v = constrain(lfoRuler1.currentValue + lfoRuler2.currentValue, -1,1);
        
        lfoRuler1.nextValue();
        lfoRuler2.nextValue();
        
        updateParameters();
        return v;
    }
    
    void draw(PGraphics g) {
      g.image(gRuler,map( _drawSliding() ,-1,1, -gRuler.width * 0.5, 0), bound.originY);
    }
    
    void drawRight(PGraphics g) {
      g.push();
      g.rotate(radians(90));
      g.translate(0, -gRuler.height);
      g.image(gRuler,map( _drawSliding() ,-1,1, -gRuler.width * 0.5, 0), bound.originY - bound.width + rulerHeight);
      g.pop();
    }
   
   void updateParameters() {
     if (frameCount % (long)(secsToChangeSpeed) == 0) {
       lfoRuler1.speed = speedRuler1 + random(-0.01, 0.01) + ampsum * 0.01;
     }
   }

}


class DisplayRulers extends AbstractDisplay {
    Ruler ruler1, ruler2; 
    PGraphics localG;
    DisplayRulers(ARect bound){
        super(bound);
        
        ruler1 = new Ruler(bound, 35);
        ruler2 = new Ruler(bound, 28);
    }

    void draw(PGraphics g) {
        
        if (super.hidden) return;

        localG = createGraphics(bound);
        localG.beginDraw();
        localG.tint(255, 200 + ampsum * 55);
        ruler1.draw(localG);
        ruler2.drawRight(localG);
        localG.endDraw();

        drawOn(localG, g, super.bound);
    }

    void bang() {
        ruler1.prepareGraphics();
        ruler2.prepareGraphics();
    }

}
