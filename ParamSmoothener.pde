class ParamSmoothener {
  
  float currentValue = 0;
  float a,b;
  
  ParamSmoothener (float secs_smoothenTime) {
    a = exp(-TWO_PI/(secs_smoothenTime * frameRate));
    b = 1.0 - a;
    currentValue = 0;
  }
  
  float nextValue(float inValue) {
    currentValue = (inValue * b) + (currentValue * a);
    return currentValue;
  }
}
