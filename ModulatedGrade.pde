//Brightness and contrast that breathe instead of push.
//
//The resting frame is the untouched look: contrast 1.0, brightness 0. Two slow
//sines and a little audio noise move it a small distance either side of that, so
//the picture stays where the owner liked it and is only very slightly alive.
//
//Applied as a loadPixels() loop over the main canvas, the same idiom
//BloomPProcess.ApplyBloom() already uses. That keeps the canvas on its current
//renderer - a fragment shader would force size() onto P2D, changing font AA and
//image() smoothing for the whole sketch, which is a far bigger visual change than
//the grade itself.

public class ModulatedGrade
{
  //how far contrast strays from 1.0. deliberately small: the POC measured
  //contrast 1.4 crushing this content from 57.8% lit pixels to 11.6%
  float Depth = 0.12;

  //how far brightness strays from 0, in 0..255 units
  float BrightnessRange = 8.0;

  //sine periods in seconds. different and not a simple multiple of each other, so
  //contrast and brightness do not rise and fall together and the result does not
  //read as one repeating gesture
  float ContrastPeriodSecs = 8.0;
  float BrightnessPeriodSecs = 13.0;

  //guard bands, so no combination of noise and sine can drive the pass somewhere
  //unintended
  float MinContrast = 0.85;
  float MaxContrast = 1.15;
  float MaxBrightness = 12.0;

  boolean enabled = true;

  LFO lfoContrast;
  LFO lfoBrightness;

  ModulatedGrade()
  {
    //speed is fraction-of-a-cycle per frame, so seconds -> speed is 1/(frameRate * secs)
    lfoContrast = new LFO(LFO.SHAPE_SINE, random(0, 1), 1.0 / (frameRate * ContrastPeriodSecs));
    lfoBrightness = new LFO(LFO.SHAPE_SINE, random(0, 1), 1.0 / (frameRate * BrightnessPeriodSecs));
  }

  //amp is the sketch's existing smoothed amplitude, passed in rather than read
  //from here - ModulatedGrade is not the main tab and has no ampsum of its own
  public void Apply(float amp)
  {
    if (!enabled) {
      return;
    }

    float contrast = 1.0 + Depth * (0.7 * lfoContrast.nextValue()
                                    + 0.3 * noiseTerm(amp));
    float brightness = BrightnessRange * lfoBrightness.nextValue();

    contrast = constrain(contrast, MinContrast, MaxContrast);
    brightness = constrain(brightness, -MaxBrightness, MaxBrightness);

    //at the resting values there is nothing to do, so skip the whole canvas
    if (contrast == 1.0 && brightness == 0.0) {
      return;
    }

    Grade(contrast, brightness);
  }

  //the audio-driven part of the modulation: fresh noise each frame, plus whatever
  //the amplitude is currently doing
  private float noiseTerm(float amp) {
    return random(-1, 1) * 0.5 + (amp - 0.5);
  }

  private void Grade(float contrast, float brightness)
  {
    loadPixels();

    //mid grey, so the two halves of the range are weighted evenly
    final float pivot = 127.5;

    for (int i = 0; i < pixels.length; i++) {
      int c = pixels[i];

      int r = (c & 0xff0000) >> 16;
      int g = (c & 0x00ff00) >> 8;
      int b = c & 0x0000ff;

      int nr = (int)((r - pivot) * contrast + pivot + brightness);
      int ng = (int)((g - pivot) * contrast + pivot + brightness);
      int nb = (int)((b - pivot) * contrast + pivot + brightness);

      //clamp rather than wrap - wrapping turns a bright pixel dark and inverts
      //the image
      if (nr < 0) nr = 0; else if (nr > 255) nr = 255;
      if (ng < 0) ng = 0; else if (ng > 255) ng = 255;
      if (nb < 0) nb = 0; else if (nb > 255) nb = 255;

      pixels[i] = 0xff000000 | (nr << 16) | (ng << 8) | nb;
    }

    updatePixels();
  }
}