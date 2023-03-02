

PGraphics drawFlipVertically(PImage img) {
  PGraphics g = createGraphics(img.width, img.height);
  g.beginDraw();
  g.push();
  g.scale(1,-1);
  g.translate(0,-img.height);
  g.image(img,0,0);
  g.pop();
  g.endDraw();
  return g;
}

PGraphics drawFlipHorizontally(PImage img) {
  PGraphics g = createGraphics(img.width, img.height);
  g.beginDraw();
  g.push();
  g.scale(-1,1);
  g.translate(-img.width,0);
  g.image(img,0,0);
  g.pop();
  g.endDraw();
  return g;
}

PGraphics drawRotate90Degrees(PImage img) {
  PGraphics g = createGraphics(img.width, img.height);
  g.beginDraw();
  g.push();
  g.rotate(radians(90));
  g.translate(0,-img.height);
  g.image(img,0,0);
  g.pop();
  g.endDraw();
  return g;
}

PGraphics drawToFit(PImage img, float w, float h) {
  PGraphics g = createGraphics(int(w),int(h));
  g.beginDraw();
  g.push();
  g.scale(img.width/h,img.height/w);
  g.image(img,0,0);
  g.pop();
  g.endDraw();
  return g;
}
