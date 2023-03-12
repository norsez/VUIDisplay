

class TypedText {
  String title = "This is untitled...";
  int charIndex = 0;
  float charPerSec;
  float charDx;
  float charFrameCount;
  color titleColor = color(0, 190, 0, 200);
  float inset = 10, fontHeight = 16;
  ARect bound;
  PGraphics textG;

  TypedText(ARect bound) {
    this.bound = bound;
    this.setCharPerSec(0.1);
  }

  void setTitle(String t) {
    this.title = t;
    this.setCharPerSec(charPerSec);
  }

  void setCharPerSec(float numCharPerSec) {
    charPerSec = numCharPerSec;
    charDx = 1.0/(charPerSec * frameRate);
    charIndex = 0;
    charFrameCount = - (1.0/ (5 * frameRate));
  }

  void draw(PGraphics g) {

    if (charIndex >= title.length() + 1) {
      g.image(textG, 0, 0);
      return;
    }

    textG = createGraphics(this.bound);
    textG.beginDraw();
    textG.push();
    textG.textSize(fontHeight);
    textG.textFont(FONT_16);
    textG.fill(titleColor);


    textG.translate(inset, inset + fontHeight);
    textG.text(this.title.substring(0, charIndex), 0, 0);

    charFrameCount++;
    if (charFrameCount >= charDx) {
      charFrameCount = 0;
      charIndex++;
    }


    textG.pop();
    textG.endDraw();

    g.image(textG, 0, 0);
  }
}

class Panel {
  ARect bound;
  TypedText typedText;

  PGraphics panel; //<>//

  Panel(ARect bound, String text) {
    this.bound = bound;


    typedText = new TypedText(bound);
    this.setText(text, 3.4);

    preparePanel();
  }

  void preparePanel() {
    this.panel = createGraphics(bound);
    this.panel.beginDraw();
    this.panel.strokeWeight(1);
    this.panel.stroke(C_GREEN, 220);
    this.panel.fill(C_GREEN, 100);
    this.panel.rect(0, 0, (int)bound.width, (int)bound.height, 4);
    this.panel.endDraw();
  }

  void setText(String text, float charPerSec) {
    typedText.title = text;
    typedText.setCharPerSec(text.length()/charPerSec);
  }

  void draw(PGraphics g) {
    g.image(this.panel, 0, 0);
    typedText.draw(g);
  }
}


class DisplayTitle extends AbstractDisplay implements StateActionCallback {


  PGraphics localG, panelG;
  Panel panel;
  ARect panelBound;

  StateSequenceController stateC;
  State state;
  int STATE_WAIT_IN = 0, STATE_IN = 1, STATE_TEXT = 2,
    STATE_WAIT = 3, STATE_OUT = 4;
  float SEC_TEXT = 4, SEC_IN_OUT = 1;
  float dxInOut, alphaPanel;

  DisplayTitle(ARect bound, ARect panelBound, String title ) {
    super(bound);
    this.panelBound = panelBound;
    panel = new Panel(this.panelBound, title);
    panel.setText(title, SEC_TEXT);

    stateC = new StateSequenceController();
    stateC.listeners.add(this);
    state = new State(STATE_WAIT_IN, 1 * frameRate);
    stateC.add(state);
    stateC.add(new State(STATE_IN, SEC_IN_OUT * frameRate));

    stateC.add(new State(STATE_TEXT, SEC_TEXT * frameRate));
    stateC.add(new State(STATE_WAIT, 4 * frameRate));

    stateC.add(new State(STATE_OUT, SEC_IN_OUT * frameRate));
    this.dxInOut = 1.0/(SEC_IN_OUT * frameRate);
  }

  void draw(PGraphics g) {
    if (super.hidden) return;
    stateC.tick();

    if (this.state.stateId == STATE_WAIT_IN) {
      return;
    }

    panelG = createGraphics(panelBound);
    panelG.beginDraw();
    panel.draw(panelG);
    panelG.endDraw();

    localG = createGraphics(bound); // draw translate only
    localG.beginDraw();

    if (this.state.stateId == STATE_WAIT) {
      localG.image(panelG, panelBound.originX, panelBound.originY, panelBound.width, panelBound.height);
    } else if (this.state.stateId == STATE_TEXT) {
      localG.image(panelG, panelBound.originX, panelBound.originY, panelBound.width, panelBound.height);
    } else if (this.state.stateId == STATE_IN) {
      localG.push();
      this.alphaPanel += this.dxInOut;
      localG.tint(255, cvLinearToExp8( this.alphaPanel ) * 255);
      localG.image(panelG, panelBound.originX, panelBound.originY, panelBound.width, panelBound.height);
      localG.pop();
    } else if (this.state.stateId == STATE_OUT) {
      localG.push();
      this.alphaPanel -= this.dxInOut;
      localG.tint(255, cvLinearToExp8(this.alphaPanel) * 255);
      localG.image(panelG, panelBound.originX, panelBound.originY, panelBound.width, panelBound.height);
      localG.pop();
    }


    if (DEBUG) {
      localG.stroke(C_PINK, 100);
      localG.fill(100, 50);
      localG.rect(0, 0, bound.width, bound.height);
    }
    localG.endDraw();

    drawOn(localG, g, bound);
  }


  void callbackWith(StateSequenceController sc, State s, PGraphics g) {
    if (sc != this.stateC) return;
    this.state = s;

    if (this.state.stateId == STATE_IN) {
      this.alphaPanel = 0;
    } else if (this.state.stateId == STATE_OUT) {
      this.alphaPanel = 1;
    }
  }

  void bang() {
  }
}
