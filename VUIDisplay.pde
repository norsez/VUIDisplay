PGraphics g;
DisplayInterface [] displays;

void initDisplays() {
  displays = new DisplayInterface [1];
  displays[0] = new TestDisplay();
}

void setup(){
  size(800,600);
  background(0);
  g = createGraphics(width,height);
  
  initDisplays();
}

void draw(){
  receiveInput();
  
  g.beginDraw();
  
  for (int i=0; i<displays.length; i++){
    displays[i].draw(g);
  }
  
  g.endDraw();
  
  image(g,0,0);
}

void receiveInput() {
  
}
