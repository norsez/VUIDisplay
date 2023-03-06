import processing.sound.*;


  final String FILENAME = "Norsez 17.wav";
  SoundFile sample;
  Waveform waveform;
  //AMP
  Amplitude rms;
  float smoothingFactorAmp = 0.25;
  float smoothingFactorFFT = 0.75;
  float ampsum;
  
  
  //FFT
  FFT fft;
  int FFT_NUM_BANDS = 512;
  float[] fftsum = new float[FFT_NUM_BANDS];
  int NUM_SAMPLES_WAVE = 64;
  List FFTBPs;
  Sound sound;
  
  void initAudioInput() {
    
    //sound = new Sound(this);
    //sound.outputDevice(3);
    //sound.volume(0.2);
    
    sample = new SoundFile(this, FILENAME);
    sample.loop();
    rms = new Amplitude(this);
    rms.input(sample);
    
    fft = new FFT(this, FFT_NUM_BANDS);
    fft.input(sample);
    
    waveform = new Waveform(this, NUM_SAMPLES_WAVE);
    waveform.input(sample);
  }
  
  void tickWave(){
    waveform.analyze();
  }
  
  float tickAmp(){
      
    // smooth the rms data by smoothing factor
    ampsum += (rms.analyze() - ampsum) * smoothingFactorAmp;
    return ampsum;
    
  }
  
  float[] tickFFT() {
    
    fft.analyze();
    for (int i = 0; i < FFT_NUM_BANDS; i++) {
      // Smooth the FFT spectrum data by smoothing factor
      fftsum[i] += (fft.spectrum[i] - fftsum[i]) * smoothingFactorFFT;
    }
    return fftsum;
    
  }
