void boardToPlotter() {
  gondolastx=sketchx[0];
  gondolasty=sketchy[0];
  for (int i = 1; i < sketchx.length; i++) {

    String gopos="G1 X" +  ((sketchx[i] -gondolastx) * printfactor) + " Y" + ((sketchy[i] -gondolasty) * -printfactor) + "\n";
    tee(gopos);
    gondolastx=sketchx[i];
    gondolasty=sketchy[i];
  }
}

void tee(String cmdline) {

  buff2plotter=append(buff2plotter, cmdline);
}

int transmit2plotter() {
  if (buff2plotter.length == 0) return 0;

  String cmdline;
  if ((connected==true) && (plotterReady==false)) return 0;

  cmdline=buff2plotter[0];
  if (buff2plotter.length ==1) {
    buff2plotter=new String[0];
  }
  else {
    String[] tmpbuff=new String[buff2plotter.length -1];
    arraycopy(buff2plotter, 1, tmpbuff, 0, buff2plotter.length -1);
    buff2plotter=tmpbuff;
  }
  print(buff2plotter.length + " -> " + cmdline);
  lblLog.setText(buff2plotter.length + " -> " + cmdline);
  lblResponse.setText("");
  if (connected==true) {
    plotterReady=false;
    myPort.write(cmdline);
  }
  return 1;
}

