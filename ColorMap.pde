String FILENAME_COLOR_MAP = "matrix.jpg";
PImage colorMapImage;


void initColorMap(boolean doResize){
  colorMapImage = loadImage(FILENAME_COLOR_MAP);
  if (doResize){
    colorMapImage.resize(width,height);
  }
  colorMapImage.loadPixels();
}

color colorFromMap(int x, int y, boolean useMap) {
  if (useMap){
    return colorMapImage.get(x,y);
  }else {
    return color(0,200,200);
  }
}

color colorFromMap(){
  return colorMapImage.get((int)random(0, colorMapImage.width), (int) random(0, colorMapImage.height));
}

color colorFromMap(int at_x, int at_y, ARect ofRect) {
  return colorMapImage.get( 
    (int)map(at_x, 0, colorMapImage.width, 0, ofRect.width),
    (int)map(at_y, 0, colorMapImage.height, 0, ofRect.height)
    );
}
