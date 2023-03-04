
PFont debugFont;
int debugFontSize = 12;
int debug_y = debugFontSize;
float debug_skipFrames = frameRate;

color C_RED = color(200,0,0,200);
color C_WHITE = color(200,200);
void debug(String txt, color c) {
  //if (frameCount % debug_skipFrames != 0) return;
  push();
  textSize(debugFontSize);
  fill(c);
  text(txt, 5, debug_y);
  pop();
  
  debug_y += debugFontSize;
  if (debug_y >= height - debugFontSize){
    debug_y = debugFontSize;
  }
}


void debug(String txt, int x, int y, PGraphics g) {
  if (DEBUG)
    debug(txt,x,y,g, color(255));
}

void debug(String txt, int x, int y, PGraphics g, color c) {
  if(!DEBUG) return;
  
  g.push();
  g.textSize(debugFontSize);
  g.fill(c);
  g.text(txt, x, y);
  g.pop();
}

void debugRed(String txt, int x, int y, PGraphics g) { 
  if(!DEBUG) return;
  
  g.push();
  g.textSize(debugFontSize);
  g.fill(255,0,0);
  g.text(txt, x, y);
  g.pop();
}
