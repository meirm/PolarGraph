import processing.core.*;
class Plotter implements PConstants {
  float pulleyRadius;
  int stepsPerRevolution;
  float cmDistBetweenPulleys;
  float cmHomeLocationX;
  float cmHomeLocationY;

  float MINRPM;
  float STARTRPM;
  float MAXRPM;

  Plotter(){
    MINRPM=10;
    STARTRPM=20;
    MAXRPM=30;
  }
  void config(float _pulleyRadius,int _stepsPerRevolution,float _cmDistBetweenPulleys,float _cmHomeLocationX,float _cmHomeLocationY) {
    pulleyRadius=_pulleyRadius;
    stepsPerRevolution=_stepsPerRevolution;
    cmDistBetweenPulleys=_cmDistBetweenPulleys;
    cmHomeLocationX=_cmHomeLocationX;
    cmHomeLocationY=_cmHomeLocationY;
  }

  void setSpeed(float minrpm, float startrpm, float maxrpm){
    MINRPM=minrpm;
    STARTRPM=startrpm;
    MAXRPM=maxrpm;
  }

  float step2mm() {
    return (TWO_PI * pulleyRadius)/stepsPerRevolution;
  }
};

void initPlotter() {

  String command="M101 F"+ myPlotter.MINRPM +"\n";
  tee(command);
  command="M102 F" + myPlotter.MAXRPM +"\n";
  tee(command);
  command="M103 F" + myPlotter.STARTRPM +"\n";
  tee(command);
}
