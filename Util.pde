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

double withMathRound(double value, int places) {
    double scale = Math.pow(10, places);
    return Math.round(value * scale) / scale;
}

String formatFreq(float value, int places) {
  String s = "";
  if (value >= 1000) {
    s = "" + Math.round(value * 0.001) + "k";
    
   }else {
    s = "" + value;
   }
   
  //int decimalIndex = s.indexOf(".");
  //s = s.substring(0, decimalIndex)  + s.substring(decimalIndex +1, decimalIndex+1 + places);
  
  return s + "Hz";
}
