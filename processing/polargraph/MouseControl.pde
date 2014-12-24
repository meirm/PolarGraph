
void mouseRelPos() {
  pointerpos.set(mouseX - mxoffset  -pg.width/2, mouseY - myoffset -pg.height/2);
}
void mousePressed() {
  mouseRelPos();

  if ((pnlDrawingBoard.isCollapsed()==false)&& (abs(pointerpos.y ) < pg.height/2) && (abs(pointerpos.x) < pg.width/2)) {
    drawLine();
  }
}

void drawLine() {
  float mrelx=pointerpos.x;
  float mrely= pointerpos.y;
  if (mouseButton == LEFT) {
    float relx=mrelx/ scalefactor - gondolastx;
    float rely= mrely/ scalefactor -gondolasty;
    String gopos="G1 X" + (relx *printfactor) + " Y" + ( -rely *printfactor) + "\n";

    sketchx=append(sketchx, mrelx/scalefactor);
    sketchy=append(sketchy, mrely/scalefactor);
    gondolastx=relx;
    gondolasty=rely;
    tee(gopos);
  }
  else if (mouseButton == RIGHT) {
    if (sketchx.length > 0) {
      sketchx=shorten(sketchx);
      sketchy=shorten(sketchy);
    }
  }
}
