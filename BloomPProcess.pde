public class BloomPProcess
{
  
  private PImage    bloomTarget;  
  
  //the bloom runs on an image this many times smaller than the canvas, then gets
  //interpolated back up. the upscale is what softens it, so the blur can stay cheap.
  private int       BloomScale      = 4;
  private int       BloomThreshold   = 100; //the minimum brightness that will be "bloomed"
  private int       BloomRadius      = 12;  //the radius of the bloom, in canvas pixels
  
  //scratch buffers for the blur, allocated once to match bloomTarget
  private int [] bufR, bufG, bufB, dv, vmin, vmax;
  private int   bufDiv;
  private int   bufW, bufH;
  
  BloomPProcess()
  {
    SetUpTarget();
  }
  
  
  //dont use this normally
  public void UpdateParams()
  {
    //BloomThreshold = int( width / 255 ) * mouseX;
    //BloomRadius = mouseY/10;
  } 
  
  //creates a texture/image to use to create and apply the bloom
  private void SetUpTarget()
  {
    int tw = max(1, width / BloomScale);
    int th = max(1, height / BloomScale);
    
    bloomTarget = createImage(tw, th, RGB);
    
    int wh = tw * th;
    bufR = new int[wh];
    bufG = new int[wh];
    bufB = new int[wh];
    vmin = new int[max(tw, th)];
    vmax = new int[max(tw, th)];
    
    bufDiv = TargetRadius() + TargetRadius() + 1;
    dv = new int[256 * bufDiv];
    for (int i = 0; i < 256 * bufDiv; i++) {
      dv[i] = (i / bufDiv);
    }
    
    bufW = tw;
    bufH = th;
  }
  
  //the radius in bloomTarget pixels, so BloomRadius stays measured in canvas pixels
  private int TargetRadius() {
    return max(1, BloomRadius / BloomScale);
  }
  
  //the scratch buffers are sized to the canvas at startup, so a resize needs new ones
  private boolean TargetIsStale() {
    return bufW != max(1, width / BloomScale)
      || bufH != max(1, height / BloomScale)
      || bufDiv != TargetRadius() + TargetRadius() + 1;
  }
  
  //called at the end of a draw loop, this applies bloom to everything on screen
  public void ApplyBloom()
  {
    if (TargetIsStale()) {
      SetUpTarget();
    }
    
    BloomExtract();
    Blur( bloomTarget , TargetRadius() );
    
    //draw the bloomed image over the scene using additive blending. image() rather than
    //blend() because image() interpolates when scaling up, and that interpolation is what
    //turns the small buffer into a smooth glow instead of a grid of blocks.
    blendMode(ADD);
    image(bloomTarget, 0, 0, width, height);
    blendMode(BLEND);
  }
  
  //keeps the brightest pixel of each BloomScale x BloomScale block ( the bloom threshold )
  private void BloomExtract()
  {
    loadPixels();
    bloomTarget.loadPixels();
    
    int scale = BloomScale;
    int tw = bloomTarget.width;
    int th = bloomTarget.height;
    int w = width;
    int h = height;
    
    for (int ty = 0; ty < th; ty++) {
      int y0 = ty * scale;
      for (int tx = 0; tx < tw; tx++) {
        int x0 = tx * scale;
        
        int br = 0, bg = 0, bb = 0;
        for (int sy = y0; sy < y0 + scale && sy < h; sy++) {
          int row = sy * w;
          for (int sx = x0; sx < x0 + scale && sx < w; sx++) {
            int c = pixels[row + sx];
            int cr = (c & 0xff0000) >> 16;
            int cg = (c & 0x00ff00) >> 8;
            int cb = c & 0x0000ff;
            if (cr > br) br = cr;
            if (cg > bg) bg = cg;
            if (cb > bb) bb = cb;
          }
        }
        
        //max is per channel, so this is never darker than the brightest pixel in the block
        int c = 0xff000000 | (br << 16) | (bg << 8) | bb;
        if (brightness(c) >= BloomThreshold) {
          bloomTarget.pixels[ty * tw + tx] = c;
        } else {
          bloomTarget.pixels[ty * tw + tx] = 0xff000000;
        }
      }
    }
    
    bloomTarget.updatePixels();
  }
  
  
  //blurs an image
  private void Blur( PImage _img , int radius )
  {
    if (radius<1)
    {
      return;
    }
    
    int w=_img.width;
    int h=_img.height;
    int wm=w-1;
    int hm=h-1;
    int wh=w*h;
    int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
    int [] pix=_img.pixels;
    
    yw=0;
    yi=0;
    
    for (y=0;y<h;y++)
    {
      rsum=gsum=bsum=0;
      for(i=-radius;i<=radius;i++){
        p=pix[yi+min(wm,max(i,0))];
        rsum+=(p & 0xff0000)>>16;
        gsum+=(p & 0x00ff00)>>8;
        bsum+= p & 0x0000ff;
     }
      for (x=0;x<w;x++)
      {
      
        bufR[yi]=dv[rsum];
        bufG[yi]=dv[gsum];
        bufB[yi]=dv[bsum];
  
        if(y==0)
        {
          vmin[x]=min(x+radius+1,wm);
          vmax[x]=max(x-radius,0);
         } 
         p1=pix[yw+vmin[x]];
         p2=pix[yw+vmax[x]];
  
        rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
        gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
        bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
        yi++;
      }
      yw+=w;
    }
    
    for (x=0;x<w;x++)
    {
      rsum=gsum=bsum=0;
      yp=-radius*w;
      for(i=-radius;i<=radius;i++){
        yi=max(0,yp)+x;
        rsum+=bufR[yi];
        gsum+=bufG[yi];
        bsum+=bufB[yi];
        yp+=w;
      }
      yi=x;
      for (y=0;y<h;y++)
      {
        pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
        if(x==0){
          vmin[y]=min(y+radius+1,hm)*w;
          vmax[y]=max(y-radius,0)*w;
        } 
        p1=x+vmin[y];
        p2=x+vmax[y];
  
        rsum+=bufR[p1]-bufR[p2];
        gsum+=bufG[p1]-bufG[p2];
        bsum+=bufB[p1]-bufB[p2];
  
        yi+=w;
      }
    }  
  }




}