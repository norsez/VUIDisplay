float mapCurve(float n_value, float expfac) {
  //normalized value only.
  return pow(n_value,expfac);
}


PGraphics createGraphics(ARect arect) {
  return createGraphics((int)arect.width,(int)arect.height);
}

ARect windowBoundingBox() {
  ARect r = new ARect(0,0,width,height);
  return r;
}
