static class LFO {
  
  static int TABLE_SIZE = 2048;
  static boolean TABLE_MADE = false;
  static float [] TABLE_SINE, TABLE_SAW, TABLE_SINE_PLUS;
  
  static final int SHAPE_SINE = 0;
  static final int SHAPE_SAW = 1;
  static final int SHAPE_SINE_PLUS = 2;
  
  float angle, speed;
  private int lfoShape = 0;
  private float lfoTable [];
  
  boolean reverseDirection; //wave going right to left
  
  float DisplaySelfDrivenTiles;
  float previousValue;
  LFO (int shape, float angel, float speed) {
    this.angle = angel;
    this.speed = speed;
    
    initTables();
    this.setShape(shape);
    
  }
  
  private static void initTables() {
    if (TABLE_MADE) {
      return;
    }
    
    TABLE_SINE = new float [TABLE_SIZE];
    TABLE_SAW = new float [TABLE_SIZE];
    TABLE_SINE_PLUS = new float[TABLE_SIZE];
    for(int i=0; i< TABLE_SIZE; i++){
      TABLE_SINE[i] = sin(TWO_PI * i / (float) TABLE_SIZE);
      TABLE_SINE_PLUS[i] = cos(PI * i / (float) TABLE_SIZE);
      TABLE_SAW[i] = map(i / (float)TABLE_SIZE, 0, 1, -1, 1);
    }
  }
  
  void setShape(int shape) {
    this.lfoShape = shape;
    if (shape == SHAPE_SINE){
      this.lfoTable = TABLE_SINE;
    }else if (shape == SHAPE_SAW) {
      this.lfoTable = TABLE_SAW;
    }else if (shape == SHAPE_SINE_PLUS) {
      this.lfoTable = TABLE_SINE_PLUS;
    }
  }
  
  float nextValue() {
    float floatIndex = reverseDirection ? (1-angle) : angle * (TABLE_SIZE-1);
    if (floatIndex >= TABLE_SIZE -1 || floatIndex < 0.0) {
      floatIndex = 0;
      //println("oops");
    }
    
    int firstIndex = floor(floatIndex);
    int nextIndex = ceil(floatIndex);
    
    //debug
    if(firstIndex < 0) {
      println("float index " + floatIndex +", firstIndex" + firstIndex + ", nextIndex" + nextIndex + ", angle" + angle);
    }
    
    float lowerV = this.lfoTable[firstIndex];
    float upperV = this.lfoTable[nextIndex];
    float interpolationAmt = (floatIndex-firstIndex);
    previousValue = DisplaySelfDrivenTiles;
    DisplaySelfDrivenTiles = lerp(lowerV, upperV, interpolationAmt);
    
    angle += speed;
    if (angle>=1) {
      angle = 0;
    }
    return DisplaySelfDrivenTiles;
  }
  
  String debugLog() {
    return "[speed: " + (int)(1.f/speed) + ", angle: ." + (int)(angle* 100) + ", rev:" + reverseDirection + " ]";
  }
}

class DualLFO {
  LFO lfo1;
  LFO lfo2; 
  float amount1 = 0.2;
  float amount2 = 0.3;
  float currentValue;
  DualLFO(){
    lfo1 = new LFO(LFO.SHAPE_SINE, random(1), 1.0/(frameRate * 5));
    lfo2 = new LFO(LFO.SHAPE_SINE, random(1), 1.0/(frameRate * 0.25));
  }
  
  float nextValue() {
    currentValue = lfo1.nextValue() * amount1 + lfo2.nextValue() * amount2;
    return currentValue;
  }
}
