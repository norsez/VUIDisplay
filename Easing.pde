
class Easing{
  
  float easing = 0.01;
  float lastValue = 1;
  float ease(float value) {
    float dx = value - lastValue;
    lastValue = lastValue + dx * easing;
    return lastValue;
  }
}
