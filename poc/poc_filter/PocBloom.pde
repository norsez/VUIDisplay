//POC-only copy of the bloom algorithm, lifted from VUIDisplay/BloomPProcess.pde.
//
//The real BloomPProcess reads the MAIN CANVAS (loadPixels() with no argument) and
//draws its result back onto the main canvas with blendMode(ADD). A post-processing
//pass needs to read an arbitrary PImage instead, so this copy takes the source and
//the destination as parameters. The extract/blur math is unchanged from the original.
//
//The real BloomPProcess.pde is NOT modified by this POC. Any refactor to make the
//real one reusable belongs in the change request, not here.

class PocBloom
{
  PImage bloomTarget;

  //same values as BloomPProcess.pde
  int BloomScale    = 4;
  int BloomThreshold = 100;
  int BloomRadius   = 12;

  //scratch buffers, allocated once per target size
  int[] bufR, bufG, bufB, dv, vmin, vmax;
  int   bufDiv, bufW, bufH;

  PocBloom() {
  }

  //draws the bloom of src additively onto dst
  //adds the bloom of src additively onto target, which the caller has already
  //drawn src into. target is a PGraphics rather than a PImage because blendMode()
  //only exists on a PGraphics - there is no way to blend into a PImage's pixels.
  void addTo(PImage src, PGraphics target) {
    setUpTarget(src.width, src.height);

    bloomExtract(src);
    blur(bloomTarget, targetRadius());

    // beginDraw()/endDraw() are required here. A PGraphics ignores draw calls made
    // outside that pair, and when this was missing the additive blit silently drew
    // nothing - the output was byte-identical to the baseline.
    target.beginDraw();

    //ADD blend, same as ApplyBloom(). image() not blend(), because image()
    //interpolates on upscale and that interpolation is what softens the glow.
    target.pushStyle();
    target.blendMode(ADD);
    target.image(bloomTarget, 0, 0, target.width, target.height);
    target.blendMode(BLEND);
    target.popStyle();

    target.endDraw();
  }

  private void setUpTarget(int w, int h) {
    int tw = max(1, w / BloomScale);
    int th = max(1, h / BloomScale);

    if (bloomTarget != null && bufW == tw && bufH == th
        && bufDiv == targetRadius() + targetRadius() + 1) {
      return; //already the right size
    }

    bloomTarget = createImage(tw, th, RGB);

    int wh = tw * th;
    bufR = new int[wh];
    bufG = new int[wh];
    bufB = new int[wh];
    vmin = new int[max(tw, th)];
    vmax = new int[max(tw, th)];

    bufDiv = targetRadius() + targetRadius() + 1;
    dv = new int[256 * bufDiv];
    for (int i = 0; i < 256 * bufDiv; i++) {
      dv[i] = (i / bufDiv);
    }

    bufW = tw;
    bufH = th;
  }

  //the radius in bloomTarget pixels, so BloomRadius stays in canvas pixels
  private int targetRadius() {
    return max(1, BloomRadius / BloomScale);
  }

  //keeps the brightest pixel of each BloomScale x BloomScale block, then thresholds it
  private void bloomExtract(PImage src) {
    src.loadPixels();
    bloomTarget.loadPixels();

    int scale = BloomScale;
    int tw = bloomTarget.width;
    int th = bloomTarget.height;
    int w = src.width;
    int h = src.height;

    for (int ty = 0; ty < th; ty++) {
      int y0 = ty * scale;
      for (int tx = 0; tx < tw; tx++) {
        int x0 = tx * scale;

        int br = 0, bg = 0, bb = 0;
        for (int sy = y0; sy < y0 + scale && sy < h; sy++) {
          int row = sy * w;
          for (int sx = x0; sx < x0 + scale && sx < w; sx++) {
            int c = src.pixels[row + sx];
            int cr = (c & 0xff0000) >> 16;
            int cg = (c & 0x00ff00) >> 8;
            int cb = c & 0x0000ff;
            if (cr > br) br = cr;
            if (cg > bg) bg = cg;
            if (cb > bb) bb = cb;
          }
        }

        int c = 0xff000000 | (br << 16) | (bg << 8) | bb;

        // luma computed by hand rather than via brightness(c). PApplet.brightness()
        // reads the sketch's colorMode off the graphics object, which is null in a
        // headless run - and the value here is a fixed 0..255 RGB threshold anyway,
        // so it never needed colorMode in the first place.
        int luma = (int)(0.299f * br + 0.587f * bg + 0.114f * bb);

        if (luma >= BloomThreshold) {
          bloomTarget.pixels[ty * tw + tx] = c;
        } else {
          bloomTarget.pixels[ty * tw + tx] = 0xff000000;
        }
      }
    }

    bloomTarget.updatePixels();
  }

  //two-pass sliding-window box blur, same as Blur() in BloomPProcess.pde
  private void blur(PImage img, int radius) {
    if (radius < 1) return;

    int w = img.width;
    int h = img.height;
    int wm = w - 1;
    int hm = h - 1;
    int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
    int[] pix = img.pixels;

    yw = 0;
    yi = 0;

    for (y = 0; y < h; y++) {
      rsum = gsum = bsum = 0;
      for (i = -radius; i <= radius; i++) {
        p = pix[yi + min(wm, max(i, 0))];
        rsum += (p & 0xff0000) >> 16;
        gsum += (p & 0x00ff00) >> 8;
        bsum += p & 0x0000ff;
      }
      for (x = 0; x < w; x++) {
        bufR[yi] = dv[rsum];
        bufG[yi] = dv[gsum];
        bufB[yi] = dv[bsum];

        if (y == 0) {
          vmin[x] = min(x + radius + 1, wm);
          vmax[x] = max(x - radius, 0);
        }
        p1 = pix[yw + vmin[x]];
        p2 = pix[yw + vmax[x]];

        rsum += ((p1 & 0xff0000) - (p2 & 0xff0000)) >> 16;
        gsum += ((p1 & 0x00ff00) - (p2 & 0x00ff00)) >> 8;
        bsum += (p1 & 0x0000ff) - (p2 & 0x0000ff);
        yi++;
      }
      yw += w;
    }

    for (x = 0; x < w; x++) {
      rsum = gsum = bsum = 0;
      yp = -radius * w;
      for (i = -radius; i <= radius; i++) {
        yi = max(0, yp) + x;
        rsum += bufR[yi];
        gsum += bufG[yi];
        bsum += bufB[yi];
        yp += w;
      }
      yi = x;
      for (y = 0; y < h; y++) {
        pix[yi] = 0xff000000 | (dv[rsum] << 16) | (dv[gsum] << 8) | dv[bsum];
        if (x == 0) {
          vmin[y] = min(y + radius + 1, hm) * w;
          vmax[y] = max(y - radius, 0) * w;
        }
        p1 = x + vmin[y];
        p2 = x + vmax[y];

        rsum += bufR[p1] - bufR[p2];
        gsum += bufG[p1] - bufG[p2];
        bsum += bufB[p1] - bufB[p2];

        yi += w;
      }
    }
  }
}