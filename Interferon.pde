/********************************************************

INTERFERON
Sohan Murthy
2017

INTERFERON is a work-in-progress LED art installation.
This program controls 320 individually addressable LEDs
through a variety of procedurally generated patterns.

*********************************************************/

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
  
  // Create the model, which describes where the light points are
  model = new Model();
 
  
  // Create the P3LX engine
  lx = new P3LX(this, model);
  
  // Set the patterns
  lx.setPatterns(new LXPattern[] {
    
    new Interference(lx),
    //new Fountain(lx),
    new BistroLights(lx),
    //new IteratorTestPattern(lx),
    //new BaseHuePattern(lx),  
    
  });
  
  //Sets the transition type 
  final LXTransition multiply = new MultiplyTransition(lx).setDuration(15*SECONDS);
  
  for (LXPattern p : lx.getPatterns()) {
    p.setTransition(multiply);
  }
  
  //Auto transitions patterns after a set period of time
  lx.enableAutoTransition(10*MINUTES);
  
  //Output to LEDs
  output = buildOutput();
  
  // Adds UI elements -- COMMENT all of this out if running on Linux in a headless environment
  size(400, 600, P3D);
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
  background(#292929);
}