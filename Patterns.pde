/*

Patterns go here dummy

*/


class BistroLights extends LXPattern{
    
  class BistroLight extends LXLayer {
    
    private final SinLFO sync = new SinLFO(6*SECONDS, 18*SECONDS, 38*SECONDS);
    private final SinLFO bright = new SinLFO(0,100, sync);
    private final SinLFO sat = new SinLFO(35,100, sync);
    private final SinLFO hueValue = new SinLFO(216, 312, sync);
    
    private int sPixel;
    private int fPixel;
    private float hOffset;
      
    BistroLight(LX lx, int s, int f, float o){
      super(lx);
      sPixel = s;
      fPixel = f;
      hOffset = o;
      addModulator(sync.randomBasis()).start();
      addModulator(bright.randomBasis()).start();
      addModulator(sat.randomBasis()).start();
      addModulator(hueValue.randomBasis()).start();
    }
    
    public void run(double deltaMs) {
      float s = sat.getValuef();
      float b = bright.getValuef();
      
      for(int i = sPixel; i < fPixel; i++){
        blendColor(i, LXColor.hsb(
          hueValue.getValuef(),
          s,
          b
          ), LXColor.Blend.LIGHTEST);
        }
    }    
    
  }
  
  BistroLights(LX lx){
   super(lx); 
    final int section = 8;
   for(int s = 0; s <= model.size-section; s+=section){
     addLayer(new BistroLight(lx, s, s+section, 0));
   }
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
    lx.cycleBaseHue(3*MINUTES);
  }
  
}



class Fountain extends LXPattern {
  
  final float size = 3.67;
  final float wth = 10;
  final float vLow = 2.8;
  final float vHigh = 3.8; 
  final float gravity = -1.5;
  final int num = 7;
 
  class Jet extends LXLayer {
    
    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, gravity);
     

    Jet(LX lx) {
      super(lx);
      addModulator(xPos).start();
      addModulator(yPos).start();
      init();
    }

    public void run(double deltaMs) {
      boolean touched = false;
      for (LXPoint p : model.points) {
          float dx = abs(p.x - xPos.getValuef());
          float dy = abs(p.y/wth - yPos.getValuef());
          float b = 100 - (100/size) * max(dx, dy);
        if (b > 0) {
          touched = true;
          blendColor(p.index, LXColor.hsb(
            (120 + (dist(p.x, p.y, model.cx, model.yMin) / model.xRange) * 180) % 360,
            45, 
            b), LXColor.Blend.LIGHTEST);
        }
      }
      if (!touched) {
        init();
      }
      
      lx.cycleBaseHue(3.3*MINUTES);
    }

    private void init() {
      xPos.setValue(random(model.xMin, model.xMax));
      yPos.setValue(random(model.yMin-3, model.yMin-3));  
      yPos.setVelocity(random(vLow, vHigh));
      
    }
  }
  
 

  Fountain(LX lx) {
    super(lx);
    for (int i = 0; i < num; ++i) {
      addLayer(new Jet(lx));
    }
  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
    
  
}


class Interference extends LXPattern {
  
      class Concentric extends LXLayer{
        
        private final SinLFO sync = new SinLFO(13*SECONDS,21*SECONDS, 34*SECONDS);
        private final SinLFO speed = new SinLFO(7700,3200, sync);
        private final SinLFO tight = new SinLFO(10,15, sync);
        
        private final SinLFO cy = new SinLFO(model.yMin, model.yMax, random(2*MINUTES+sync.getValuef(),3*MINUTES+sync.getValuef()));
        private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
        
        private final float cx;
        private final int slope = 25;
        
        
        Concentric(LX lx, float x){
        super(lx);
        addModulator(sync.randomBasis()).start();
        addModulator(speed.randomBasis()).start();
        addModulator(tight.randomBasis()).start();
        addModulator(move.randomBasis()).start();
        
        cx = x;
        addModulator(cy.randomBasis()).start();
        }
        
         public void run(double deltaMs) {
           for(LXPoint p : model.points) {
           float dx = (dist(p.x, p.y, cx, cy.getValuef()))/ slope;
           float b = 12 + 12 * sin(dx * tight.getValuef() + move.getValuef());
             blendColor(p.index, LXColor.hsb(
             216,
             25,
             b
             ), LXColor.Blend.ADD); 
           }
         }
      }
  
  Interference(LX lx){
    super(lx);
    addLayer(new Concentric(lx, model.xMin));
    addLayer(new Concentric(lx, model.cx));
    addLayer(new Concentric(lx, model.xMax));
  }
  
  public void run(double deltaMs) {
    setColors(#000000);
    
  }

}