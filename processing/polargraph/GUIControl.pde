public void handleStickEvents(GStick stick, GEvent event) { 
  if (joystick == stick) {
    int pos = stick.getPosition();
    if (pos > -1) {// Stick is in rest position?
      println("Pos: "+ pos);
      println("X-> " + stick.getStickX());
      println("Y-> " + stick.getStickY());
      viewoffset.set(viewoffset.x+stick.getStickX()*20, viewoffset.y+stick.getStickY()*20);
    }
  }
}

void resetViewOffset(){
viewoffset.set(0.0,0.0);
}
