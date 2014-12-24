/*
MyPolar controller 
 by Meir Michanie
 meirm@riunx.com
 
 Description:
 
 Specifications:
 All record are in relative positions to (0,0)
 Input/Output file in relative positions to (0,0)
 Each time we draw in the screen, we convert to absolute position.
 The vertical axis of the screen is inverted and therefore, we will swap the direction when converting to absolute value.
 
 TODO:
 show progress bar buffer empty...
 
 */
import java.awt.Rectangle;
import java.util.ArrayList;
import processing.serial.*;
import g4p_controls.*;

PGraphics pg;
PGraphics pgProgressBar;

String[] buff2plotter= new String[0];
String[] serialString;  
// A JSON object
JSONObject json;

boolean plotterReady=true;
boolean nodraw=false;

String serialCheck;  
String portName = "/dev/ttyACM";
int portNumber;  
int serialIndex;  
//color bgcolor=(200, 200, 255);			     // Background color
Serial myPort;                       // The serial port
boolean connected = false;
boolean showgrid = false;
float scalefactor=1.0;
float printfactor=1.0;
float gondolastx;
float gondolasty;
float drawzonex=600.0;
float drawzoney=400.0;
float myoffset=100.0;
float mxoffset=100.0;
float[] sketchx = new float[0];
float[] sketchy= new float[0];
Plotter myPlotter=new Plotter();
float step2mm;
String strwelcomeNote;
float totallength=0;
PVector pointerpos= new PVector(0.0, 0.0);
PVector ProgressBar= new PVector(mxoffset, 530);
PVector viewoffset= new PVector(0.0, 0.0);
JSONArray PlottersData;
JSONObject SelectedPlotter;
String configText;

void setup() {
  size(800, 600);  // Stage size
  loadConfig();
  int ss=88;
  joystick = new GStick(this, width-ss, height-ss, ss, ss);
  joystick.setMode(G4P.X8);
  calcPlotterDimmensions();
  progressBar();
  clearProgressBar();
  clearGraphic();
  createConfMenu();
  createControlMenu();
  createMiscMenu();
  createTopMenu();
  noStroke();      // No border on the next thing drawn
  initboard();
  // Print a list of the serial ports, for debugging purposes:
  println(Serial.list());
}


void draw() {
  if (nodraw==false) {
    background(200, 200, 255);
    if (plotterReady==true) transmit2plotter();
    if (frameCount % 2 == 0)    updateGraphic();
  }
  updateProgressBar();
  image(pgProgressBar, ProgressBar.x, ProgressBar.y);
}
void calcPlotterDimmensions() {
  step2mm=(float)myPlotter.step2mm();
  println("10 step == " + step2mm + "mm");
}


void wipeBoard() {
  sketchx=new float[0];
  sketchx=append(sketchx, gondolastx);//- pg.width/2);
  sketchy=new float[0];
  sketchy=append(sketchy, gondolasty);// - pg.height/2);
}
void updateGraphic() {
  clearGraphic();
  if (showgrid==true)showGrid(); 
  pg.beginDraw();
  pg.stroke(0, 255, 0);
  pg.noFill();
  pg.translate(viewoffset.x, viewoffset.y);
  pg.translate(pg.width/2, pg.height/2);
  pg.beginShape();
  totallength=0;
  Float minvX, minvY, maxvX, maxvY, currvX, currvY;
  minvX=minvY=maxvX=maxvY=currvX=currvY=0.0;
  for (int i = 0; i < sketchx.length; i++) {
    totallength+=max(abs(sketchx[i]), abs(sketchy[i]));
    currvX= sketchx[i];
    if (currvX < minvX) minvX=currvX;
    if (currvX > maxvX) maxvX=currvX;
    currvY=sketchy[i]; 
    if (currvY < minvY) minvY=currvY;
    if (currvY > maxvY) maxvY=currvY;
    pg.vertex(((sketchx[i])*scalefactor), ((sketchy[i])*scalefactor));
  }
  //  scalefactor=max(0.1,0.5*pg.width/max(0.1,(maxvX+abs(minvX))));
  //  scalefactor=min(scalefactor,max(0.1,0.5*pg.height/max(0.01,(maxvY+abs(minvY)))));
  //  scalefactor=constrain(scalefactor,0.1,10.0);
  // txfScaleFactor.setText("" + scalefactor +"");
  lblPrintSizeValue.setText((maxvX+abs(minvX))*printfactor/10.0 + " x " + (maxvY+abs(minvY))*printfactor/10.0);
  long secs=int(totallength*printfactor*0.01/(step2mm*myPlotter.STARTRPM));
  int hours=int(secs/3600);
  int min=int(secs%3600/60);
  lblPrintTimeValue.setText(String.format("%02d:%02d:%02d", hours, min, secs%60));
  pg.endShape();
  if (sketchx.length >0) {
    gondolastx=(sketchx[sketchx.length-1]);
    gondolasty=(sketchy[sketchx.length-1]);
    pg.stroke(0, 0, 255);
    mouseRelPos();
    if ((abs(pointerpos.x) < pg.width/2) && (abs(pointerpos.y) < pg.height)) {
      pg.line(pointerpos.x, pointerpos.y, gondolastx* scalefactor, gondolasty * scalefactor);

      lblXYpos.setText("X=" + pointerpos.x + " Y=" +  -1*(pointerpos.y));
    }
  }
  showGondola();
  pg.endDraw();
}

void closeConnection() {
  myPort.stop();
  connected=false;
}
public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) { 
  if (textcontrol == txfPrintFactor) {
    printfactor=float(txfPrintFactor.getText());
  }
  else if (textcontrol == txfScaleFactor) {
    scalefactor=float(txfScaleFactor.getText());
  }
}

public void handlePanelEvents(GPanel panel, GEvent event) {
  lblDebug.setText("Panel: " + event);
  if (event == GEvent.EXPANDED) {
    if (panel == pnlDrawingBoard) {
      pnlDrawingBoard.setCollapsed(false);
      pnlPlotterConf.setCollapsed(true);
    }
    else  if (panel == pnlPlotterConf) {

      pnlDrawingBoard.setCollapsed(true);
      pnlPlotterConf.setCollapsed(false);
    }
  }
  /* code */
}

void showGondola() {

  pg.beginDraw();
  pg.translate(viewoffset.x, viewoffset.y);
  pg.translate(pg.width/2, pg.height/2);
  pg.fill(255, 20, 0, 100);
  pg.noStroke();
  ellipseMode(CENTER);
  if (sketchx.length>1)  pg.ellipse(gondolastx*scalefactor, gondolasty*scalefactor, 15, 15);
  pg.fill(0, 20, 255, 100);
  pg.noStroke();
  if (sketchx.length>1)  pg.ellipse(sketchx[0]*scalefactor, sketchy[0]*scalefactor, 15, 15);

  pg.endDraw();
}
void showGrid() {
  showgrid=true;
  pg.beginDraw();
  pg.stroke(230, 230, 230, 100);

  for (int i=0; i< drawzoney; i+=10) {
    pg.line(0, i, pg.width, i);
  }
  for (int i=0; i< drawzonex; i+=10) {
    pg.line(i, 0, i, pg.height);
  }
  pg.stroke(255, 0, 0, 20);
  pg.line(drawzonex/2.0, 0, drawzonex/2.0, pg.height);
  pg.line(0, drawzoney/2.0, pg.width, drawzoney/2.0);
  pg.endDraw();
}

void hideGrid() {
  showgrid=false;
  clearGraphic();
}


public void handleSliderEvents(GValueControl slider, GEvent event) {
  //  scalefactor=slider.getValueF();
  println("scalefactor=" +scalefactor);
}
// Handles events from checkbox and option controls.
public void handleToggleControlEvents(GToggleControl checkbox, GEvent event) {
  if (checkbox == cbxShowGrid) {
    PApplet.useNativeSelect = cbxShowGrid.isSelected();
    if (cbxShowGrid.isSelected()==true) {
      showGrid();
    }
    else {
      hideGrid();
    }
  }
}
void handleButtonEvents(GButton button, GEvent event) { 
  if (button == btnClear) {
    wipeBoard();
  }
  else if (button == btnConnect) {
    if (button.getText() == "Connect") {
      makeConnection();
      initPlotter();
      button.setText("Disconnect");
    }
    else {
      button.setText("Connect");
      closeConnection();
    }
  }
  else if (button == btnDraw) {
    boardToPlotter();
  }
  else if (button == btnQuit) {
    exit();
  } 
  else if (button == btnSave) {
    selectOutput("Save as:", "saveSketch");
  }  
  else if (button == btnLoad) {
    selectInput("Load file:", "loadSketch");
  }
  else if (button == btnSaveConfig) {
    saveConfig();
  }
  else if (button == btnLoadConfig) {
    loadConfig();
  }
  else if (button== btnApplyConfig) {
    applyConfig();
  }
  else if (button == btnSend) {
    if (cbxBypass.isSelected() ==true) {
      lblLog.setText(txfCommand.getText());
      if (connected==true) myPort.write(txfCommand.getText() +"\n");
    }
    else {
      tee(txfCommand.getText() +"\n");
    }
  } 
  else if (button == btnOK) {
    tee("M100\n");
  }
  else if (button == btnCWR) {
    for (int i = 0; i < sketchx.length; i++) {
      float tmp=sketchx[i];
      sketchx[i]=-sketchy[i];
      sketchy[i]=tmp;
    }
  }
  else if (button == btnCCWR) {
    for (int i = 0; i < sketchx.length; i++) {
      float tmp=-sketchx[i];
      sketchx[i]=sketchy[i];
      sketchy[i]=tmp;
    }
  }
  else if ( button ==btnVMirror) {
    for (int i = 0; i < sketchy.length; i++) {
      sketchy[i]*=-1;
    }
  }
  else if ( button ==btnHMirror) {
    for (int i = 0; i < sketchx.length; i++) {
      sketchx[i]*=-1;
    }
  }
  else if (button == btnEnable) {
    if (button.getText() == "Enable") {
      button.setText("Disable");
      tee("M85\n");
    }
    else {
      button.setText("Enable");
      tee("M84\n");
    }
  }
  else if (button == btnHome) {
    gondolastx=pg.width/2.0;
    gondolasty=pg.height/2.0;
    clearGraphic();
    tee("M090\n");
    tee("M091\n");
  }
  else if (button == btnPause) {
    if (connected==true) {
      String abuff[]= {
        "M80\n"
      };
      buff2plotter=concat( abuff, buff2plotter);
    }
  }
  else if (button == btnContinue) {
    if (connected==true) {
      cbxBypass.setSelected(false);
      myPort.write("M81\n");
    }
  }
  else if (button == btnAbort) {
    if (connected==true) {
      buff2plotter=new String[0];
    }
  }
  else if (button == btnReset) {
    initPlotter();
    initboard();
  }
  else if (button == btnCenterView) {
    resetViewOffset();
  }
}

void showHome() {
  pg.beginDraw();
  pg.fill(255, 0, 0);
  pg.noStroke();
  ellipseMode(CENTER);
  pg.ellipse(pg.width/2.0, pg.height/2.0, 3.0, 3.0);
  pg.endDraw();
}
// Clear the sketchpad graphic
void clearGraphic() {
  pg.beginDraw();
  pg.background(255);
  pg.endDraw();
  showHome();
}
void loadSketch(File selection) {
  String myfile="lines.txt";
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    //return;
  } 
  else {
    println("User selected " + selection.getAbsolutePath());
    myfile=selection.getPath();
  }
  nodraw=true;
  String[] lines = loadStrings(myfile);
  sketchx= new float[0];
  sketchy= new float[0];
  for (int i=0; i<  lines.length; i++) {
    String[] pieces = split(lines[i], '\t');
    if (pieces.length == 2) {
      sketchx=append (sketchx, float( pieces[0]));
      sketchy=append (sketchy, float( pieces[1]));
    }
  }
  nodraw=false;
}
void saveSketch(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    return;
  } 
  else {
    println("User selected " + selection.getAbsolutePath());
  }
  String[] lines = new String[sketchx.length +1];

  for (int i = 0; i < sketchx.length; i++) {
    lines[i] = sketchx[i] + "\t" + sketchy[i];
  }
  lines[sketchx.length]=";end of file";
  saveStrings(selection.getAbsolutePath(), lines);
}
//handlePanelEvents(GPanel panel, GEvent event) { /* code */ }

void keyPressed() {
  if (key == 'c' || key=='C') {
    wipeBoard();
  }
  else if (key == 'i' || key=='I') {
    initPlotter();
  }
  else if (key == 'e' || key=='E') {
    btnEnable.setText("Disable");
    String command="M85\n";
    tee(command);
  }
  else if (key == 'd' || key=='D') {
    btnEnable.setText("Enable");
    String command="M84\n";
    tee(command);
  }
  else if (key == 'q' || key=='Q') {
    exit();
  }
  else if (key == 'h') {
    tee("M090\n");
  }
  else if (key == 'H') {
    tee("M091\n");
  }
  else if (key== 'r') {
    resetViewOffset();
  }
}


void initboard() {
  gondolastx=0;//pg.width/2.0;
  gondolasty=0;//pg.height/2.0;

  sketchx=append(sketchx, 0);
  sketchy=append(sketchy, 0);
  wipeBoard();
}



void serialEvent(Serial myPort) {

  // get the ASCII string:
  String inString = myPort.readString();

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    inString.toUpperCase();
    lblResponse.setText(inString);
    if (inString.equals("OK")) {
      println("OK");
      if (cbxBypass.isSelected()==false) plotterReady=true;
    }
    else if (inString.equals("READY")) {
      println("READY");
      plotterReady=true;
    }
    else {
      println(inString);
      plotterReady=true;
    }
  }
}

