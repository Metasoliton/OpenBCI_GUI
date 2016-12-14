
////////////////////////////////////////////////////
//
//  W_accelerometer is used to visiualze accelerometer data
//
//  Created: Joel Murphy
//  Modified: Colin Fausnaught, September 2016
//  Modified: Wangshu Sun, November 2016
//
//
///////////////////////////////////////////////////,

class W_accelerometer extends Widget {

  //to see all core variables/methods of the Widget class, refer to Widget.pde
  //put your custom variables here...

  // color boxBG;
  color graphStroke = #d2d2d2;
  color graphBG = #f5f5f5;
  color textColor = #000000;

  color strokeColor;

  // Accelerometer Stuff
  int AccelBuffSize = 500; //points registered in accelerometer buff

  int padding = 5;

  // bottom xyz graph
  int AccelWindowWidth;
  int AccelWindowHeight;
  int AccelWindowX;
  int AccelWindowY;

  // circular 3d xyz graph
  float PolarWindowX;
  float PolarWindowY;
  int PolarWindowWidth;
  int PolarWindowHeight;
  float PolarCorner;

  color eggshell;
  color Xcolor;
  color Ycolor;
  color Zcolor;

  float currentXvalue;
  float currentYvalue;
  float currentZvalue;

  int[] X;
  int[] Y;
  int[] Z;

  float dummyX;
  float dummyY;
  float dummyZ;
  boolean Xrising;
  boolean Yrising;
  boolean Zrising;
  boolean OBCI_inited= true;

  int navOffset = 44;

  Button accelModeButton;

  W_accelerometer(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    // boxBG = bgColor;
    strokeColor = color(138, 146, 153);

    // Accel Sensor Stuff
    eggshell = color(255, 253, 248);
    Xcolor = color(255, 36, 36);
    Ycolor = color(36, 255, 36);
    Zcolor = color(36, 100, 255);

    setGraphDimensions();

    // XYZ buffer for bottom graph
    X = new int[AccelBuffSize];
    Y = new int[AccelBuffSize];
    Z = new int[AccelBuffSize];

    // for synthesizing values
    Xrising = true;
    Yrising = false;
    Zrising = true;

    // initialize data
    for (int i=0; i<X.length; i++) {  // initialize the accelerometer data
      X[i] = AccelWindowY + AccelWindowHeight/4; // X at 1/4
      Y[i] = AccelWindowY + AccelWindowHeight/2;  // Y at 1/2
      Z[i] = AccelWindowY + (AccelWindowHeight/4)*3;  // Z at 3/4
    }

    if(eegDataSource == DATASOURCE_GANGLION){
      accelModeButton = new Button((int)(x + 3), (int)(y + navHeight + 3), 120, navHeight - 6, "Hardware Settings", 12);
      accelModeButton.setCornerRoundess((int)(navHeight-6));
      accelModeButton.setFont(p6,10);
      // accelModeButton.setStrokeColor((int)(color(150)));
      // accelModeButton.setColorNotPressed(openbciBlue);
      accelModeButton.setColorNotPressed(color(57,128,204));
      accelModeButton.textColorNotActive = color(255);
      // accelModeButton.setStrokeColor((int)(color(138, 182, 229, 100)));
      accelModeButton.hasStroke(false);
      // accelModeButton.setColorNotPressed((int)(color(138, 182, 229)));
      accelModeButton.setHelpText("The buttons in this panel allow you to adjust the hardware settings of the OpenBCI Board.");
    }

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    // addDropdown("Thisdrop", "Drop 1", Arrays.asList("A", "B"), 0);
    // addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

  }

  public void initPlayground(OpenBCI_ADS1299 _OBCI) {
    OBCI_inited = true;
  }

  void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)

    //put your code here...
    if (isRunning) {
      if (eegDataSource == DATASOURCE_SYNTHETIC) {
        synthesizeAccelerometerData();
        currentXvalue = map(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
        currentYvalue = map(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
        currentZvalue = map(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight, 4.0, -4.0);
        shiftWave();
      } else if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {
        currentXvalue = openBCI.validAuxValues[0] * openBCI.get_scale_fac_accel_G_per_count();
        currentYvalue = openBCI.validAuxValues[1] * openBCI.get_scale_fac_accel_G_per_count();
        currentZvalue = openBCI.validAuxValues[2] * openBCI.get_scale_fac_accel_G_per_count();
        X[X.length-1] =
          int(map(currentXvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Y[Y.length-1] =
          int(map(currentYvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Z[Z.length-1] =
          int(map(currentZvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else if (eegDataSource == DATASOURCE_GANGLION) {
        currentXvalue = ganglion.accelArray[0] * ganglion.get_scale_fac_accel_G_per_count();
        currentYvalue = ganglion.accelArray[1] * ganglion.get_scale_fac_accel_G_per_count();
        currentZvalue = ganglion.accelArray[2] * ganglion.get_scale_fac_accel_G_per_count();
        X[X.length-1] =
          int(map(currentXvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        X[X.length-1] = constrain(X[X.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Y[Y.length-1] =
          int(map(currentYvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Y[Y.length-1] = constrain(Y[Y.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);
        Z[Z.length-1] =
          int(map(currentZvalue, -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));
        Z[Z.length-1] = constrain(Z[Z.length-1], AccelWindowY, AccelWindowY+AccelWindowHeight);

        shiftWave();
      } else {  // playback data
        currentXvalue = accelerometerBuff[0][accelerometerBuff[0].length-1];
        currentYvalue = accelerometerBuff[1][accelerometerBuff[1].length-1];
        currentZvalue = accelerometerBuff[2][accelerometerBuff[2].length-1];
      }
    }
  }

  void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    //put your code here...
    //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    if (true) {
      // fill(graphBG);
      // stroke(strokeColor);
      // rect(x, y, w, h);
      // textFont(f4, 24);
      // textAlign(LEFT, TOP);
      // fill(textColor);
      // text("Acellerometer Gs", x + 10, y + 10);

      fill(50);
      textFont(f4, 16);
      text("z", PolarWindowX-12, (PolarWindowY-PolarWindowHeight/2));
      text("x", (PolarWindowX-PolarWindowWidth/2)+2, PolarWindowY-15);
      text("y", (PolarWindowX-PolarCorner)-5, (PolarWindowY+PolarCorner)-20);

      fill(graphBG);  // pulse window background
      stroke(graphStroke);
      rect(AccelWindowX, AccelWindowY, AccelWindowWidth, AccelWindowHeight);

      fill(graphBG);  // pulse window background
      stroke(graphStroke);
      ellipse(PolarWindowX,PolarWindowY,PolarWindowWidth,PolarWindowHeight);

      stroke(180);
      line(PolarWindowX-PolarWindowWidth/2, PolarWindowY, PolarWindowX+PolarWindowWidth/2, PolarWindowY);
      line(PolarWindowX, PolarWindowY-PolarWindowHeight/2, PolarWindowX, PolarWindowY+PolarWindowHeight/2);
      line(PolarWindowX-PolarCorner, PolarWindowY+PolarCorner, PolarWindowX+PolarCorner, PolarWindowY-PolarCorner);

      fill(50);
      textFont(f4, 30);

      if (eegDataSource == DATASOURCE_NORMAL_W_AUX) {  // LIVE
        // fill(Xcolor);
        // text("X " + nf(currentXvalue, 1, 3), x+10, y+40);
        // fill(Ycolor);
        // text("Y " + nf(currentYvalue, 1, 3), x+10, y+80);
        // fill(Zcolor);
        // text("Z " + nf(currentZvalue, 1, 3), x+10, y+120);
        drawAccValues();
        draw3DGraph();
        drawAccWave();
      } else if (eegDataSource == DATASOURCE_GANGLION) {
        accelModeButton.draw();
        drawAccValues();
        draw3DGraph();
        drawAccWave();
      } else if (eegDataSource == DATASOURCE_SYNTHETIC) {  // SYNTHETIC
        // fill(Xcolor);
        // text("X "+nf(currentXvalue, 1, 3), x+10, y+40);
        // fill(Ycolor);
        // text("Y "+nf(currentYvalue, 1, 3), x+10, y+80);
        // fill(Zcolor);
        // text("Z "+nf(currentZvalue, 1, 3), x+10, y+120);
        drawAccValues();
        draw3DGraph();
        drawAccWave();
      }
      else {  // PLAYBACK
        drawAccValues();
        draw3DGraph();
        drawAccWave2();
      }
    }

    // pushStyle();
    // textFont(h1,24);
    // fill(bgColor);
    // textAlign(CENTER,CENTER);
    // text(widgetTitle, x + w/2, y + h/2);
    // popStyle();

  }

  void setGraphDimensions(){
    AccelWindowWidth = w - padding*2;
    AccelWindowHeight = int((float(h) - float(navOffset) - float(padding*3))/2.0);
    AccelWindowX = x + padding;
    AccelWindowY = y + h - AccelWindowHeight - padding;

    // PolarWindowWidth = 155;
    // PolarWindowHeight = 155;
    PolarWindowWidth = AccelWindowHeight;
    PolarWindowHeight = AccelWindowHeight;
    PolarWindowX = x + w - padding - PolarWindowWidth/2;
    PolarWindowY = y + navOffset + padding + PolarWindowHeight/2;
    PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
  }

  void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    //put your code here...
    // AccelWindowWidth = int(w) - 10;
    // AccelWindowX = int(x)+5;
    // AccelWindowY = int(y)-10+int(h)/2;
    //
    // PolarWindowX = x+AccelWindowWidth-90;
    // PolarWindowY = y+83;
    // PolarCorner = (sqrt(2)*PolarWindowWidth/2)/2;
    setGraphDimensions();

    if(eegDataSource == DATASOURCE_GANGLION){
      accelModeButton.setPos((int)(x + 3), (int)(y + navHeight + 3));
    }
  }

  void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

    //put your code here...
    if(eegDataSource == DATASOURCE_GANGLION){
      //put your code here...
      if (accelModeButton.isMouseHere()) {
        accelModeButton.setIsActive(true);
      }
    }
  }

  void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

    //put your code here...
    if(eegDataSource == DATASOURCE_GANGLION){
      //put your code here...
      if(accelModeButton.isActive && accelModeButton.isMouseHere()){
        println("toggle...");
        if(ganglion.isAccelModeActive()){
          ganglion.accelStop();

          accelModeButton.setString("Turn Accel On");
        } else{
          ganglion.accelStart();
          accelModeButton.setString("Turn Accel Off");
        }
      }
      accelModeButton.setIsActive(false);
    }

  }

  //add custom classes functions here
  void drawAccValues() {
    fill(Xcolor);
    text("X " + nf(currentXvalue, 1, 3), x+10, y + 30 + navOffset);
    fill(Ycolor);
    text("Y " + nf(currentYvalue, 1, 3), x+10, y + 70 + navOffset);
    fill(Zcolor);
    text("Z " + nf(currentZvalue, 1, 3), x+10, y + 110 + navOffset);
  }

  void shiftWave() {
    for (int i = 0; i < X.length-1; i++) {      // move the pulse waveform by
      X[i] = X[i+1];
      Y[i] = Y[i+1];
      Z[i] = Z[i+1];
    }
  }

  void draw3DGraph() {
    noFill();
    strokeWeight(3);
    stroke(Xcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map(currentXvalue, -4.0, 4.0, -77, 77), PolarWindowY);
    stroke(Ycolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX+map((sqrt(2)*currentYvalue/2), -4.0, 4.0, -77, 77), PolarWindowY-map((sqrt(2)*currentYvalue/2), -4.0, 4.0, -77, 77));
    stroke(Zcolor);
    line(PolarWindowX, PolarWindowY, PolarWindowX, PolarWindowY+map(currentZvalue, -4.0, 4.0, -77, 77));
  }

  void drawAccWave() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < X.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, X[i]);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < Y.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, Y[i]);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < Z.length; i++) {
      int xi = int(map(i, 0, X.length-1, 0, AccelWindowWidth-1));
      vertex(AccelWindowX+xi, Z[i]);
    }
    endShape();
  }

  void drawAccWave2() {
    noFill();
    strokeWeight(1);
    beginShape();                                  // using beginShape() renders fast
    stroke(Xcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int x = int(map(accelerometerBuff[0][i], -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      x = constrain(x, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, x);                    //draw a line connecting the data points
    }
    endShape();

    beginShape();
    stroke(Ycolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int y = int(map(accelerometerBuff[1][i], -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      y = constrain(y, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, y);
    }
    endShape();

    beginShape();
    stroke(Zcolor);
    for (int i = 0; i < accelerometerBuff[0].length; i++) {
      int z = int(map(accelerometerBuff[2][i], -4.0, 4.0, float(AccelWindowY+AccelWindowHeight), float(AccelWindowY)));  // ss
      z = constrain(z, AccelWindowY, AccelWindowY+AccelWindowHeight);
      vertex(AccelWindowX+i, z);
    }
    endShape();
  }

  void synthesizeAccelerometerData() {
    if (Xrising) {  // MAKE A SAW WAVE FOR TESTING
      X[X.length-1]--;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] <= AccelWindowY) {
        Xrising = false;
      }
    } else {
      X[X.length-1]++;   // place the new raw datapoint at the end of the array
      if (X[X.length-1] >= AccelWindowY+AccelWindowHeight) {
        Xrising = true;
      }
    }

    if (Yrising) {  // MAKE A SAW WAVE FOR TESTING
      Y[Y.length-1]--;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] <= AccelWindowY) {
        Yrising = false;
      }
    } else {
      Y[Y.length-1]++;   // place the new raw datapoint at the end of the array
      if (Y[Y.length-1] >= AccelWindowY+AccelWindowHeight) {
        Yrising = true;
      }
    }

    if (Zrising) {  // MAKE A SAW WAVE FOR TESTING
      Z[Z.length-1]--;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] <= AccelWindowY) {
        Zrising = false;
      }
    } else {
      Z[Z.length-1]++;   // place the new raw datapoint at the end of the array
      if (Z[Z.length-1] >= AccelWindowY+AccelWindowHeight) {
        Zrising = true;
      }
    }
  }

};

// //These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
// void Thisdrop(int n){
//   println("Item " + (n+1) + " selected from Dropdown 1");
//   if(n==0){
//     //do this
//   } else if(n==1){
//     //do this instead
//   }
//
//   closeAllDropdowns(); // do this at the end of all widget-activated functions to ensure proper widget interactivity ... we want to make sure a click makes the menu close
// }
//
// void Dropdown2(int n){
//   println("Item " + (n+1) + " selected from Dropdown 2");
//   closeAllDropdowns();
// }
//
// void Dropdown3(int n){
//   println("Item " + (n+1) + " selected from Dropdown 3");
//   closeAllDropdowns();
// }