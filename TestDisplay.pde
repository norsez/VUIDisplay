class TestDisplay extends AbstractDisplay {
  
  TestDisplay(ARect b){
    super(b);
  }
  
  void draw(PGraphics g){
    
    if (mousePressed){
      for (int i=0; i< 4; i++){
        g.fill(255,255,255,0);
        g.stroke(0,255,0,1);
        g.ellipse(mouseX,mouseY,random(10,100),random(10,100));
      }
    }
  }
}
