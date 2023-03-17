class DisplayGridMove extends AbstractDisplay {

  int numRows, numCols;
  int tx, ty; //width and height of cell
  float strokeInset = 1;
  float round = 8;
  PGraphics gGrid, gCell;

  int state = 0;
  final int STATE_WAIT = 0, STATE_BLINK = 1;
  int numToBlink = 3;
  float currentFrame = 0;
  LFO lfoBlink;

  DisplayGridMove(ARect bound) {
    super(bound);
    lfoBlink = new LFO(LFO.SHAPE_SAW, 0, 0.05);
    prepareGraphics();
  }

  void prepareGraphics() {

    numRows = width>height?(int)random(2, 6):(int)random(4,10);
    numCols = (int)(bound.width/(bound.height/float(numRows)));
    gCell = createGraphics(int(bound.width/numCols), int(bound.height/numRows));
    tx = gCell.width;
    ty = gCell.height;

    gCell.beginDraw();
    gCell.strokeWeight(strokeInset);
    gCell.stroke(color(140, 201 + random(-30, 10), 185), 50 + random(10));
    gCell.noFill();
    float inset = 0.0;
    gCell.rect(inset, inset, gCell.width, gCell.height, round);
    gCell.endDraw();

    gGrid = createGraphics(bound);
    gGrid.beginDraw();
    for (int r=0; r<numRows; r++) {
      for (int c=0; c<numCols; c++) {
        float alpha = random(100, 190);
        gGrid.tint(255, alpha);
        gGrid.image(gCell, 0, 0);
        gGrid.fill(colorFromMap(), alpha);
        gGrid.noStroke();
        gGrid.textFont(FONT_6);
        gGrid.text(randomString(4), 8, 8);

        gGrid.translate(tx, 0);
      }
      gGrid.translate(-tx * numCols, 0);
      gGrid.translate(0, ty);
    }
    gGrid.endDraw();
  }

  void draw(PGraphics g) {
    g.image(gGrid, 0, 0);

    if (state == STATE_WAIT) {
      if ((long)currentFrame <= 0) {
        state = STATE_BLINK;
        numToBlink = (int)random (3, max(numRows, numCols));
        currentFrame = 0;
      }
    } else if (state == STATE_BLINK ) {
      g.push();
      //g.blendMode(SCREEN);
      float alpha = 255 * lfoBlink.nextValue();
      g.tint(255, alpha);
      g.image(gCell, _bX, _bY, gCell.width, gCell.height);
      g.pop();
      
      g.stroke(C_DEFAULT_FILL, alpha );
      g.strokeWeight(2);
      g.noFill();
      g.rect(_bX, _bY, gCell.width, gCell.height, round);
      

      if ((long)currentFrame <= 0) {
        calcNewBlinkRound(); //<>//
      }
    }
    currentFrame--;
  }

  float blinkX, blinkY, _bX, _bY;
  float lastBlinkX, lastBlinkY;

  void calcNewBlinkRound() {

    currentFrame = 0.66 * frameRate;
    lfoBlink.speed = 1.0/(ampsum * 5);

 //<>//

    lastBlinkX = blinkX;
    lastBlinkY = blinkY;
    
    // blinkX = (int)constrain(random(-1, 5)>0?2:1 + lastBlinkX, 0, numCols);
    // blinkY = (int)constrain(random(-1, 3)>0?2:1 + lastBlinkY, 0, numRows);
   blinkX = (int)random(0, numCols);
   blinkY = (int)random(0, numRows); 
   _bX = blinkX * gCell.width; //<>//
    _bY = blinkY * gCell.height;


    numToBlink -= 1; //<>//
    if (numToBlink == 0) { //<>//
      state = STATE_WAIT;
      currentFrame = random(1.2, 2.5) * frameRate;
      blinkX = blinkY = lastBlinkX = lastBlinkY = 0;
    }

    pdebug("blink x,y" + blinkX + ", " + blinkY 
    + "\nlast blink x,y" + lastBlinkX + ", " + lastBlinkY 
    + "\nnumToBlink = " + numToBlink 
    + "\ncurrentFrame: " + currentFrame);
  }

  void bang() {
    prepareGraphics();
    calcNewBlinkRound();
  }
}
