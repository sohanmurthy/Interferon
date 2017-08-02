/*

Bistro Lights

*/

class BistroLights extends LXPattern{

  class BistroLight extends LXLayer {

    private final SinLFO sync = new SinLFO(6*SECONDS, 18*SECONDS, 38*SECONDS);
    private final SinLFO bright = new SinLFO(0,100, sync);
    private final SinLFO sat = new SinLFO(20,45, sync);
    private final TriangleLFO hueValue = new TriangleLFO(0, 77, sync);

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
          lx.getBaseHuef() + hueValue.getValuef() + hOffset,
          //lx.getBaseHuef() + hOffset,
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
     if((s+section) % (section*2) == 0){
     addLayer(new BistroLight(lx, s, s+section, 67));
     }else{
       addLayer(new BistroLight(lx, s, s+section, 0));
     }  
   }
  }

  public void run(double deltaMs) {
    setColors(#000000);
    lx.cycleBaseHue(9.6*MINUTES);
  }

}



/*

Interference

*/

class Interference extends LXPattern {

      class Concentric extends LXLayer{

        private final SinLFO sync = new SinLFO(13*SECONDS,21*SECONDS, 34*SECONDS);
        private final SinLFO speed = new SinLFO(7700,3200, sync);
        private final SinLFO tight = new SinLFO(10,15, sync);

        private final TriangleLFO cy = new TriangleLFO(model.yMin, model.yMax, random(2*MINUTES+sync.getValuef(),3*MINUTES+sync.getValuef()));
        private final SawLFO move = new SawLFO(TWO_PI, 0, speed);
        
        private final TriangleLFO hue = new TriangleLFO(0,180, sync);

        private final float cx;
        private final int slope = 25;

        Concentric(LX lx, float x){
        super(lx);
        cx = x;
        addModulator(sync.randomBasis()).start();
        addModulator(speed.randomBasis()).start();
        addModulator(tight.randomBasis()).start();
        addModulator(move.randomBasis()).start();
        addModulator(hue.randomBasis()).start();
        addModulator(cy.randomBasis()).start();
        }

         public void run(double deltaMs) {
           for(LXPoint p : model.points) {
           float dx = (dist(p.x, p.y, cx, cy.getValuef()))/ slope;
           float b = 16 + 16 * sin(dx * tight.getValuef() + move.getValuef());
           float s = b;
             blendColor(p.index, LXColor.hsb(
             lx.getBaseHuef()+hue.getValuef(),
             s,
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
    lx.cycleBaseHue(11.2*MINUTES);
  }

}



class Sequencer extends LXPattern {
  

  
  final float size = 3;
  final float wth = 6;
  final float vLow = 2.8;
  final float vHigh = 3.8;
  final int num = 18;
 
  class Sequence extends LXLayer {
    
      private final SinLFO jerk = new SinLFO(-1, 0.2, 18*SECONDS);
      //private final float gravity = jerk.getValuef();
    
    private final Accelerator xPos = new Accelerator(0, 0, 0);
    private final Accelerator yPos = new Accelerator(0, 0, jerk);
     

    Sequence(LX lx) {
      super(lx);
      addModulator(jerk.randomBasis()).start();
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
            (lx.getBaseHuef() + (dist(p.x, p.y, model.cx, model.yMin) / model.xRange) * 180) % 360,
            35, 
            b), LXColor.Blend.LIGHTEST);
        }
      }
      if (!touched) {
        init();
      }
      lx.cycleBaseHue(3.7*MINUTES);
    }

    private void init() {
      xPos.setValue(random(model.xMin-5.25, model.xMax+5.25));
      yPos.setValue(random(model.yMin-3, model.yMin-3));  
      yPos.setVelocity(random(vLow, vHigh));
      
    }
  }
  
 

  Sequencer(LX lx) {
    super(lx);
    for (int i = 0; i < num; ++i) {
      addLayer(new Sequence(lx));
    }

  }

  public void run(double deltaMs) {
    setColors(#000000);
  }
    
  
}