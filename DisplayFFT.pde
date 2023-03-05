import java.util.ArrayList;
import java.util.*;


class DisplayFFTAlphaBall extends AbstractDisplay {
  int maxInstances = 24;
  final int ONE_INIT = 1;
  List<AlphaBall> balls;
  float fftscale = 25;
  float partOfFTT = 0.10;
  PGraphics lg;
  
  
  DisplayFFTAlphaBall (ARect bound) {
    super(bound);
    balls = new ArrayList();
    lg = createGraphics(super.bound);
  }

  float getRadius() {
    return map(constrain(controlA, -100, 100), -100, 100, 1.3, 17);
  }

  float getVelocity() {
    return map(constrain(controlB, -100, 100), -100, 100, 2, bound.width * 10);
  }

  color getColorStroke() {
    return color(0, 190, 0, 190);
  } 
 
  void draw(PGraphics g) {
    
    if (super.hidden) return;
    lg = createGraphics(bound);
    
    lg.beginDraw();
    balls.removeIf((b -> b.dead));
    if (balls.size() >= maxInstances + mapCtrlA( 1024, 1)) {
        balls = balls.subList(maxInstances, balls.size() - 1);
        pdebug("flush balls", C_RED);
    }
    pdebug(balls.size() + " balls.");

    if (mousePressed) {
      

      float vel = this.getVelocity();
      float radius = this.getRadius();
      for (int i=0; i<ONE_INIT; i++) {
        AlphaBall b = new AlphaBall(mouseX + (i * 2), mouseY, bound);
        b.radius = radius + (i * 2);
        b.vel_px_per_sec = vel + (i * 25);
        balls.add(b);
      }
    } else  {
      float x_d = lg.height/(FFT_NUM_BANDS * partOfFTT);
      for (int i=0; i < FFT_NUM_BANDS * partOfFTT; i++) {
        AlphaBall b = new AlphaBall( map(i, 0, FFT_NUM_BANDS-1, 1, fftscale) * lg.height * (fftsum[i]), i * x_d, bound);
        //AlphaBall b = new AlphaBall( lg.width * ampsum * fftscale, i * x_d, g);
        b.radius = 0.4;
        b.maxRadius = 3 + random(1,3) +  mapCtrlA( 20, 1) + random(0.2,1) * mapCtrlA( 20, 1);
        b.vel_px_per_sec = 0.05 + mapCtrlA( 1, 1000) ;
        b.alpha = ampsum * (mapCtrlA( 60,1) + random(0.2,1) * 7);
        balls.add(b);
        
        int y = 10;
        //pdebug("radius: " + getRadius() + ", " + getRadius()*3);
        
      }
    }

    for (AlphaBall b : balls) {
      b.draw(lg);
      //printDebug(b, lg);
    }
    
    lg.endDraw();
    
    drawOn(lg, g, bound);
    
    //updateParams();
  }
  
  void printDebug(AlphaBall b, PGraphics g) {
    //if (!DEBUG) return;
    pdebug("" + b.baseX +", " + b.baseY, (int)b.baseX, (int) b.baseY, g);
    
  }
  void updateParams() {
    maxInstances = int(map(controlD, -100,100, 128, 2000));
  }
}
