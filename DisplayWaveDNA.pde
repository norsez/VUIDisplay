class DisplayWaveDNA extends AbstractDisplay { //<>// //<>// //<>//

  float secsPerSnapshot;
  PGraphics buffer;
  float framePast = 0;
  float frameToUpdate = 0;
  float [] waveformBuf;
  List<Easing> easings;

  float _strokeCtrlA;
  float _fillCtrlA;
  float _radiusCtrlA;
  float _easingCtrlA, _lineLenControlA;

  LFO lfoBulbBrigtness; 

  DisplayWaveDNA(ARect bound) {
    super(bound);
    buffer = createGraphics(bound);
    setSecsPerSnapshot(1);

    easings = new ArrayList();
    for (int i=0; i<NUM_SAMPLES_WAVE; i++) {
      Easing e = new Easing();
      e.easing = 0.05;
      e.lastValue = bound.height * 0.5;
      easings.add(e);
    }

    lfoBulbBrigtness = new LFO(LFO.SHAPE_SINE, 0, 7/frameRate);
  }

  void setSecsPerSnapshot(float secs) {
    this.secsPerSnapshot = secs;
    frameToUpdate = secs * frameRate;
    framePast = frameToUpdate;
  }


  void draw(PGraphics g) {
    if (super.hidden) return;
    buffer = createGraphics(bound);
    buffer.beginDraw();
    

    float spacing = bound.width/NUM_SAMPLES_WAVE;
    buffer.strokeWeight(1);
    
    

    waveformBuf = new float[NUM_SAMPLES_WAVE];
    for (int i=0; i< NUM_SAMPLES_WAVE-1; i++) {
      easings.get(i).easing = _easingCtrlA ;
      waveformBuf[i] = easings.get(i).ease(map(waveform.data[i], -1, 1, bound.height, 0));
      buffer.stroke(colorFromMap(i * (int)spacing, (int)waveformBuf[i], true), _strokeCtrlA);
      buffer.strokeWeight(random(0.1, 7));

      float lineLen = map(waveformBuf[i+1], -1, 1, bound.height, 0);
      buffer.line(i * spacing, 
                  waveformBuf[i],
                  (i+1) * spacing, 
                  lineLen);

      float r =  2 + i * lfoBulbBrigtness.currentValue * 15.0 / NUM_SAMPLES_WAVE;
      r += waveform.data[i] * _lineLenControlA;
      //pdebug("lfo " + lfoBulbBrigtness.currentValue);
      buffer.pushStyle();
      buffer.fill(colorFromMap(), 30);
      buffer.ellipse(i * spacing, waveformBuf[i], r, r);
      buffer.stroke(colorFromMap(), random(20, 80));
      buffer.popStyle();

    }


    buffer.endDraw();
    g.push();
    buffer.tint(255, 200+ ampsum * 55);
    drawOn(buffer, g, bound);
    g.pop();
    framePast += 1;
    updateParams();
    lfoBulbBrigtness.nextValue();
  }

  

void updateParams() {
    if (frameCount % APP_PARAM_UPDATE_RATE != 0) return;
    _strokeCtrlA = mapCtrlA(100,50) + 40;
    _fillCtrlA = 45 + mapCtrlA(70,0);
    _radiusCtrlA =  mapCtrlA(0, 5);
    _easingCtrlA = mapCtrlA(0.01, 0.9);
    _lineLenControlA = mapCtrlA(1, 0) * bound.height * ampsum;
  }

void bang() {
    for(int i=0; i<easings.size(); i++) {
      easings.get(i).lastValue = random(-0.1,0.1);
    }
    _easingCtrlA = 0.9;
  }
}

