GStick joystick;
GPanel pnlDrawingBoard;
GPanel pnlPlotterConf;
GSketchPad spad;
GCheckbox cbxShowGrid;
GCheckbox cbxBypass;
GButton btnClear;
GButton btnEnable;
GButton btnHome;
GButton btnOK;
GButton btnReset;
GButton btnConnect;
GButton btnSave;
GButton btnCenter;
GButton btnLoad;
GButton btnQuit;
GButton btnDraw;
GButton btnHMirror;
GButton btnVMirror;
GButton btnCWR;
GButton btnCCWR;
GButton btnSend;
GButton btnPause;
GButton btnContinue;
GButton btnAbort;
GButton btnSaveConfig;
GButton btnApplyConfig;
GButton btnLoadConfig;
GButton btnCenterView;
GTextField txfPrintFactor;
GTextField txfScaleFactor;
GTextField txfCommand;
GLabel lblDebug;
GLabel lblXYpos;
GLabel lblPrintFactor;
GLabel lblScaleFactor;
GLabel lblLog;
GLabel lblResponse;
GLabel lblPrintSize;
GLabel lblPrintSizeValue;
GLabel lblPrintTime;
GLabel lblPrintTimeValue;
GTextArea txaconfig;
//########################################
void updateProgressBar() {
  pgProgressBar.beginDraw();
  pgProgressBar.background(255, 100);
  if ((buff2plotter.length > 1) && (sketchx.length >1)) {
    if (buff2plotter.length <sketchx.length +1) {
      pgProgressBar.fill(0);
      pgProgressBar.rect(0, 0, pgProgressBar.width* buff2plotter.length /sketchx.length, 10);
    }
  }
  pgProgressBar.endDraw();
}

void clearProgressBar() {
  pgProgressBar.beginDraw();
  pgProgressBar.background(255);
  pgProgressBar.endDraw();
}
void progressBar(){
  pg = createGraphics(int(drawzonex), int(drawzoney), JAVA2D);
  pgProgressBar = createGraphics(int(drawzonex),10,JAVA2D);
}

void createConfMenu(){
  txaconfig = new GTextArea(this, 0, 0, 290, 300, G4P.SCROLLBARS_BOTH | G4P.SCROLLBARS_AUTOHIDE);
  txaconfig.setText(configText, 310);
  pnlPlotterConf = new GPanel(this, (width - drawzonex)/2+101, (height- drawzoney)/2 -20, 100, 20, "Plotter Conf");
  btnSaveConfig=new GButton(this, 0, 0, 80, 20, "Save");
  btnApplyConfig=new GButton(this, 0, 0, 80, 20, "Apply");
  btnLoadConfig=new GButton(this, 0, 0, 80, 20, "Load");
  pnlPlotterConf.addControl(txaconfig,-101,20);
  pnlPlotterConf.addControl(btnSaveConfig,-101,330);
    pnlPlotterConf.addControl(btnApplyConfig,0,330);
  pnlPlotterConf.addControl(btnLoadConfig,101,330);
}

void createControlMenu(){
  btnCWR  = new GButton(this, 4, 150, 80, 20, "CWR");
  btnCCWR  = new GButton(this, 4, 175, 80, 20, "CCWR");
  btnPause  = new GButton(this, 4, 200, 80, 20, "Pause");
  btnContinue  = new GButton(this, 4, 225, 80, 20, "Continue");
  btnAbort  = new GButton(this, 4, 275, 80, 20, "Abort");
  btnHMirror = new GButton(this, 4, 100, 80, 20, "HMirror");
  btnVMirror = new GButton(this, 4, 125, 80, 20, "VMirror");
}

void createMiscMenu(){
  btnCenterView = new GButton(this, width-85, height-120, 80, 20, "Center");
}

void createTopMenu(){
  // Create the panel and add the controls
  pnlDrawingBoard = new GPanel(this, (width - drawzonex)/2, (height- drawzoney)/2 -20, 100, 20, "Drawing board");
  
  spad = new GSketchPad(this, mxoffset, myoffset, drawzonex, drawzoney);
  // Set the graphic for this control. 
  // The graphic will be scaled to fit the control.
  spad.setGraphic(pg);
  // Create the button to clear the graphic
  btnClear = new GButton(this, 0, 0, 80, 20, "Clear");
  btnOK = new GButton(this, 80, 0, 80, 20, "OK?");
  btnEnable = new GButton(this, 160, 0, 80, 20, "Enable");
 
  btnHome  = new GButton(this, 240, 0, 80, 20, "Home");
  btnReset  = new GButton(this, 320, 0, 80, 20, "Reset");
  btnConnect  = new GButton(this, 400, 0, 80, 20, "Connect");
  btnDraw  = new GButton(this, 480, 0, 80, 20, "Draw");
  btnSave  = new GButton(this, 560, 0, 80, 20, "Save");
  btnLoad  = new GButton(this, 640, 0, 80, 20, "Load");
  btnQuit  = new GButton(this, 720, 0, 80, 20, "Quit");
  cbxShowGrid = new GCheckbox(this, 4, 75, 120, 20, "Show Grid");
  cbxShowGrid.setSelected(false);
  cbxBypass = new GCheckbox(this, 500, 50, 120, 20, "Bypass Buffer");
  cbxBypass.setSelected(false);
  lblXYpos = new GLabel(this, (drawzonex+mxoffset)/2, drawzoney +myoffset, 190, 50, "X=0.0 Y=0.0");
  lblXYpos.setTextAlign(GAlign.LEFT, null);
  lblXYpos.setTextAlign(GAlign.CENTER, GAlign.TOP);
  lblXYpos.setTextBold();
  lblLog = new GLabel(this, 175, 26, 300, 50, "PolarGraph by Meir Michanie");
  lblLog.setTextAlign(GAlign.LEFT, null);
  lblLog.setTextAlign(GAlign.LEFT, GAlign.TOP);
  lblLog.setTextBold();
  lblResponse = new GLabel(this, 405, 25, 330, 50, "---");
  lblResponse.setTextAlign(GAlign.LEFT, null);
  lblResponse.setTextAlign(GAlign.LEFT, GAlign.TOP);
  lblResponse.setTextBold();
  lblDebug =new GLabel(this, 0, 570, 200, 30, strwelcomeNote);
  lblDebug.setTextAlign(GAlign.LEFT, null);
  txfCommand= new GTextField(this, 175, 50, 215, 20, G4P.SCROLLBARS_AUTOHIDE);
  txfCommand.setDefaultText("");
  btnSend= new GButton(this, 405, 50, 80, 20, "Send");

  txfScaleFactor= new GTextField(this, 114, 50, 44, 20, G4P.SCROLLBARS_AUTOHIDE);
  txfScaleFactor.setText("" + scalefactor +"");
  lblPrintFactor = new GLabel(this, 4, 28, 100, 44, "Print Factor:");
  lblPrintFactor.setTextAlign(GAlign.LEFT, null);
  lblPrintFactor.setTextAlign(GAlign.CENTER, GAlign.TOP);
  lblPrintFactor.setTextBold();
  txfPrintFactor= new GTextField(this, 114, 26, 44, 20, G4P.SCROLLBARS_AUTOHIDE);
  txfPrintFactor.setText("" + printfactor +"");
  lblScaleFactor = new GLabel(this, 4, 52, 100, 44, "Scale Factor:");
  lblScaleFactor.setTextAlign(GAlign.LEFT, null);
  lblScaleFactor.setTextAlign(GAlign.CENTER, GAlign.TOP);
  lblScaleFactor.setTextBold();
  lblPrintSize = new GLabel(this, 100, drawzoney +myoffset, 120, 44, "Print size (mm):");
  lblPrintSize.setTextAlign(GAlign.LEFT, null);
  lblPrintSize.setTextAlign(GAlign.LEFT, GAlign.TOP);
  lblPrintSize.setTextBold();
  lblPrintSizeValue = new GLabel(this, 220, drawzoney +myoffset, 200, 44, " x mm * y mm");
  lblPrintSizeValue.setTextAlign(GAlign.LEFT, null);
  lblPrintSizeValue.setTextAlign(GAlign.LEFT, GAlign.TOP);
  lblPrintTime = new GLabel(this, drawzonex - 40, drawzoney +myoffset, 120, 44, "Print Time: ");
  lblPrintTime.setTextAlign(GAlign.LEFT, null);
  lblPrintTime.setTextAlign(GAlign.LEFT, GAlign.TOP);
  lblPrintTime.setTextBold();
  lblPrintTimeValue = new GLabel(this, drawzonex+40, drawzoney +myoffset, 200, 44, " hh:mm:ss");
  lblPrintTimeValue.setTextAlign(GAlign.LEFT, null);
  lblPrintTimeValue.setTextAlign(GAlign.LEFT, GAlign.TOP);
//  lblPulleyRadius = new GLabel(this, 0, 0, 100, 44, "Pulley Radius:");
//  lblPulleyRadius.setTextAlign(GAlign.LEFT, null);
//  lblPulleyRadius.setTextAlign(GAlign.CENTER, GAlign.TOP);
//  lblPulleyRadius.setTextBold();
//  txfPulleyRadius= new GTextField(this, 0, 0, 44, 20, G4P.SCROLLBARS_AUTOHIDE);
//  txfPulleyRadius.setText("" + myPlotter.pulleyRadius +"");
//
//  pnlPlotterConf.addControl(lblPulleyRadius,-101,25);
//  pnlPlotterConf.addControl(txfPulleyRadius,0,25);
//  lblStepRevolution = new GLabel(this, 0, 0, 100, 44, "Steps per Rev:");
//  lblStepRevolution.setTextAlign(GAlign.LEFT, null);
//  lblStepRevolution.setTextAlign(GAlign.CENTER, GAlign.TOP);
//  lblStepRevolution.setTextBold();
//  txfStepRevolution= new GTextField(this, 0, 0, 44, 20, G4P.SCROLLBARS_AUTOHIDE);
//  txfStepRevolution.setText("" + myPlotter.stepsPerRevolution +"");
//
//  pnlPlotterConf.addControl(lblStepRevolution,-101,50);
//  pnlPlotterConf.addControl(txfStepRevolution,0,50);
  
  pnlDrawingBoard.addControl(spad, 0,20);
  // Expand the panel
  pnlDrawingBoard.setCollapsed(false);
  pnlPlotterConf.setCollapsed(true);

}
