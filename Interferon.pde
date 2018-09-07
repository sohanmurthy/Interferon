/**********************************************************

INTERFERON
Sohan Murthy
2017

INTERFERON is an LED art installation located in a private
residence in San Francisco. This program controls 320
individually addressable LEDs, which mimics interference
patterns we see everywhere in nature: ripples in a pond,
wheat fields blowing in the wind, and waves colliding on
the beach.

***********************************************************/

import ddf.minim.*;

final static int INCHES = 1;
final static int FEET = 12*INCHES;
final static int SECONDS = 1000;
final static int MINUTES = 60*SECONDS;

Model model;
P3LX lx;
LXOutput output;
UI3dComponent pointCloud;

void setup() {

  model = new Model();
  lx = new P3LX(this, model);

  lx.setPatterns(new LXPattern[] {

   new Interference(lx),
   new Aurora(lx),
   new ColorSwatches(lx),

  });

  final LXTransition multiply = new MultiplyTransition(lx).setDuration(9.2*MINUTES);

  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }

  lx.enableAutoTransition(67*SECONDS);

  output = buildOutput();

  // Adds UI elements -- COMMENT all of this out if running on Linux in a headless environment
  size(300, 400, P3D);
  lx.ui.addLayer(
    new UI3dContext(lx.ui)
    .setCenter(model.cx, model.cy, model.cz)
    .setRadius(6*FEET)
    .setTheta(PI/6)
    .setPhi(PI/64)
    .addComponent(pointCloud = new UIPointCloud(lx, model).setPointSize(4))
  );

}


void draw() {
  background(#131313);
}
