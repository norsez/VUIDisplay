class DisplayGridMove extends AbstractDisplay {

  int numRows, numCols;
  int tx, ty; //width and height of cell
  PGraphics gGrid;

  DisplayGridMove(ARect bound) {
    super(bound);
    prepareGraphics();
  }

  void prepareGraphics() {
    float strokeInset = 1;
    float round = 8;
    numRows =(int)random(2,6);
    numCols = (int)(bound.width/(bound.height/float(numRows)));
    PGraphics gCell = createGraphics(int(bound.width/numCols), int(bound.height/numRows));
    tx = gCell.width;
    ty = gCell.height;
    //PGraphics mask = createGraphics(gCell.width, gCell.height);
    //mask.beginDraw();
    //float maskInset = 0.25;
    //mask.noStroke();
    //mask.fill(255);
    //float padding = mask.width * maskInset;
    //mask.rect(0, 0, padding, mask.height);
    //mask.rect(0, padding, 0, padding);
    //mask.endDraw();

    gCell.beginDraw();
    gCell.strokeWeight(strokeInset);
    gCell.stroke(color(140,201 + random(-30, 10),185), 50 + random(10));
    gCell.noFill();
    float inset = 0.0;
    gCell.rect(inset, inset, gCell.width - strokeInset - inset*2, gCell.height - strokeInset - inset * 2, round);
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
  }
  
  void bang(){
    prepareGraphics();
  }
}
