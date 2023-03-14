class DisplayGridMove extends AbstractDisplay {

  int numRows, numCols;
  int tx, ty; //width and height of cell
  float strokeInset = 1;
    float round = 8;
  PGraphics gGrid, gCell;

  int state = 0;
  final int STATE_WAIT = 0, STATE_BLINK = 1;
  float dxWait = 1 * frameRate, dxBlink = 3 * frameRate;
  int numToBlink = 3;
  float currentFrame = 0;
  LFO lfoBlink;

  DisplayGridMove(ARect bound) {
    super(bound);
    lfoBlink = new LFO(LFO.SHAPE_SAW,0, 0.05);
    prepareGraphics();
  }

  void prepareGraphics() {
    
    numRows =(int)random(2,6);
    numCols = (int)(bound.width/(bound.height/float(numRows)));
    gCell = createGraphics(int(bound.width/numCols), int(bound.height/numRows));
    tx = gCell.width;
    ty = gCell.height;

    gCell.beginDraw();
    gCell.strokeWeight(strokeInset);
    gCell.stroke(color(140,201 + random(-30, 10),185), 50 + random(10));
    gCell.noFill();
    float inset = 0.0;
    gCell.rect(inset, inset, gCell.width, gCell.height, round);
    gCell.endDraw();

    gGrid = createGraphics(bound);
    gGrid.beginDraw();
    for (int r=0; r<numRows; r++) {
      for (int c=0; c<numCols; c++) {
        float alpha = random(100,190);
        gGrid.tint(255, alpha);
        gGrid.image(gCell, 0, 0);
        gGrid.fill(colorFromMap(), alpha);
        gGrid.noStroke();
        gGrid.textFont(FONT_6);
        gGrid.text(randomString(4), 8,8);
        
        gGrid.translate(tx, 0);
      }
      gGrid.translate(-tx * numCols, 0);
      gGrid.translate(0, ty);
    }
    gGrid.endDraw();
  }

  void draw(PGraphics g) {
    g.image(gGrid,0,0);

    if (state == STATE_WAIT) {
      if (currentFrame % dxWait == 0) {
        state = STATE_BLINK;
        numToBlink = (int)random (2,5);
        currentFrame = 0;
      }

    }else if (state == STATE_BLINK ) {
      g.push();
      g.blendMode(SCREEN);
      float alpha = 220 * lfoBlink.nextValue();
      g.tint(C_DEFAULT_FILL, alpha);
      g.image(gCell,blinkX, blinkY, gCell.width, gCell.height);
      g.pop();
      g.fill(C_DEFAULT_FILL, alpha * 0.1);
      g.rect(blinkX, blinkY, gCell.width, gCell.height, round);

      if (currentFrame % dxBlink == 0) {
        calcNewBlinkRound(); //<>//
      }
    }
    currentFrame++;
  }

  float blinkX, blinkY;

  void calcNewBlinkRound() {
    currentFrame = 0;
    dxBlink = random(0.5,2.5) * frameRate;
    lfoBlink.speed = random(0.1, 1.5);
  
    blinkX = int(gCell.width * (int)random(0, numCols-1));
    blinkY = int(gCell.height * (int)random(0, numRows-1));
    numToBlink -= 1;
    if (numToBlink == 0){ //<>//
      state = STATE_WAIT;
    }
  }
  
  void bang(){
    prepareGraphics();
    calcNewBlinkRound();
  }
}
