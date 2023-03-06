interface DisplayInterface {
  void draw(PGraphics g);
  
  void toggleHidden();
  boolean isHidden();
  void setHidden(boolean h);
  void bang();
}
