class DisplayWaveSnapshot extends AbstractDisplay { //<>//

  float secsPerSnapshot;
  PGraphics buffer;
  float framePast = 0;
  float frameToUpdate = 0;

  DisplayWaveSnapshot(ARect bound) {
    super(bound);
    buffer = createGraphics(bound);
    setSecsPerSnapshot(1);
  }

  void setSecsPerSnapshot(float secs) {
    this.secsPerSnapshot = secs;
    frameToUpdate = secs * frameRate;
    framePast = frameToUpdate;
  }


  void draw(PGraphics g) {
    if (super.hidden) return;

    buffer.beginDraw();
    buffer.background(0,1);
    

    if (framePast >= frameToUpdate) {
      float spacing = bound.width/NUM_SAMPLES_WAVE;
      buffer.strokeWeight(1);
      for (int i=0; i< NUM_SAMPLES_WAVE-1; i++) {
        buffer.stroke(colorFromMap(), 190);
        buffer.strokeWeight(3);
        float y = map(waveform.data[i],-1,1,bound.height,0);
        buffer.ellipse(i * spacing, y, 3, 3);
        buffer.stroke(colorFromMap(), 100);
        buffer.line(i * spacing, y ,
          (i+1) * spacing, map(waveform.data[i+1],-1,1,bound.height,0));
      }
      framePast = 0;
    }
    buffer.endDraw();
    drawOn(buffer, g, bound);
    framePast += 1;
  }
}
