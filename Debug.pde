
PFont debugFont;
int debugFontSize = 12;
int debug_y = debugFontSize;

float framesToShowLogEntries = 24;

color C_RED = color(200,0,0,200);
color C_WHITE = color(200,200);
color C_PINK = color(244,0,245);
color C_GREEN = color(0,220,0);
PGraphics logG;

ArrayList<LogEntry> logList = new ArrayList();

class LogEntry {
  String text; //<>//
  color colour; //<>//
  LogEntry(String s, color c){
    this.text = s;
    this.colour = c;
  }
}

void _addLogList(String s, color c) {

  if (logList.size() > 50) {
    logList = new ArrayList();
  }

  LogEntry e = new LogEntry(s,c);
  logList.add(e);

}

void pdebug(String txt) {
  pdebug(txt,C_WHITE);
}

void pdebug(String txt, color c) {
  if(DEBUG) {
    _addLogList(txt, C_WHITE);
    println(txt);
  }
}

void showLogList(PGraphics g) {
  
  if(!DEBUG) return;

  if(int(frameCount) % int(framesToShowLogEntries) == 0) {

  logG = createGraphics(width,height);
  logG.beginDraw();
  logG.textSize(debugFontSize);
  logG.translate(5,0);
  for(LogEntry e: logList) {
      logG.fill(e.colour);
      logG.text(e.text, 0, 0);
      logG.translate(0, debugFontSize);
  }
  
  logG.endDraw();
  }
  
  if (DEBUG){
    g.push();
    g.image(logG, 0, 0);
    g.pop();
  }


}


void pdebug(String txt, int x, int y, PGraphics g) {
  if (DEBUG)
    pdebug(txt,x,y,g, color(255));
}

void pdebug(String txt, int x, int y, PGraphics g, color c) {
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
