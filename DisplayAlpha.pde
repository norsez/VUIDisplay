import java.util.ArrayList;
import java.util.*;


class DisplayFFT extends AbstractDisplay {
  int maxInstances = 24;
  final int ONE_INIT = 1;
  List<AlphaBall> balls;
  float fftscale = 25;
  float partOfFTT = 0.10;
  ARect bound;
  
  DisplayFFT (ARect bound) {
    this.bound = bound;
    balls = new ArrayList();
    controlA = -100;
    controlB = -100;
  }

  float getRadius() {
    return map(constrain(controlA, -100, 100), -100, 100, 1.3, 7);
  }

  float getVelocity() {
    return map(constrain(controlB, -100, 100), -100, 100, 0.3, 45) + random(-0.5, 0.5);
  }

  color getColorStroke() {
    return color(0, 190, 0, 190);
  } 
 
  void draw(PGraphics g) {
    
    if (super.hidden) return;
    
    
    if (balls.size() >= maxInstances) {
        balls = balls.subList(ONE_INIT, balls.size() - 1);
     }

    if (mousePressed) {
      

      float vel = this.getVelocity();
      float radius = this.getRadius();
      for (int i=0; i<ONE_INIT; i++) {
        AlphaBall b = new AlphaBall(mouseX + (i * 2), mouseY, g);
        b.radius = radius + (i * 2);
        b.velocity_secs_per_round = vel + (i * 25);
        balls.add(b);
      }
    } else  {
      float x_d = g.height/(bands * partOfFTT);
      for (int i=0; i < bands * partOfFTT; i++) {
        AlphaBall b = new AlphaBall( map(i, 0, bands-1, 1, fftscale) * g.height * (fftsum[i]), i * x_d, g);
        //AlphaBall b = new AlphaBall( g.width * ampsum * fftscale, i * x_d, g);
        b.radius =  this.getRadius() ;
        b.maxRadius = b.radius + map(controlC, -100,100, 4, 25);
        b.velocity_secs_per_round = this.getVelocity();
        balls.add(b);
      }
    }

    for (AlphaBall b : balls) {
      b.draw(g);
      printDebug(b, g);
    }
    
   
    
    //updateParams();
  }
  
  void printDebug(AlphaBall b, PGraphics g) {
    debug("" + b.baseX +", " + b.baseY, (int)b.baseX, (int) b.baseY, g);
    
  }
  void updateParams() {
    maxInstances = int(map(controlD, -100,100, 128, 2000));
  }
}
