boolean DEBUG = false;
PFont debugFont;
int debugFontSize = 12;

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
