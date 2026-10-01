

long APP_FRAME_RATE = 24;
long APP_PARAM_UPDATE_RATE = (long)(APP_FRAME_RATE * 0.25);
long count_APP_PARAM_UPDATE_RATE = APP_PARAM_UPDATE_RATE;


void tickAllRates() {
  
  
  if (count_APP_PARAM_UPDATE_RATE <= 0) {
    count_APP_PARAM_UPDATE_RATE = APP_PARAM_UPDATE_RATE;
  }
  
  count_APP_PARAM_UPDATE_RATE -= 1;


}

boolean shouldUpdateParams() {
  return count_APP_PARAM_UPDATE_RATE <= 0;
}



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

String randomString(int len) {
  String s = "";
  for(int i=0; i<len; i++) {
    s += (char)random(33,177);
  }
  return s;
}
