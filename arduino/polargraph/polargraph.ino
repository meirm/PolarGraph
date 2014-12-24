/*
##################################
 #
 #   PolarGraph V6
 #
 # by Meir Michanie
 #
 ##################################
 FEATURES:
 * We have Speed
 * rel/abs coordinates
 * Support for G2 and G3
 
 
 TODO:
 * Add notion of absolute and relative home coordinates.
 * Add Support for ARC with Radians.
 
 BUGS:
 
 */

#include <EEPROM.h>
#include <EEPROMReadAny.h>
#include <EasyDriver.h>
#include <Servo.h>

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

int pos = 0;    // variable to store the servo position

#define ledPin 13


#define DEBUG 0
// Define two steppers and the pins they will use
#define CW 1
#define CCW 0
#define stepPinM1  2  // PB1
#define dirPinM1  3  // PB2
#define stepPinM2  6 // PB3
#define dirPinM2  7  // PB4
#define disPinM1  14 //
#define disPinM2  16
#define SERVOPIN 10
#define ledPIN 13
#define RESETCFGPIN 11
#define PI 3.1415926535897932384626433832795
#define HALF_PI 1.5707963267948966192313216916398
#define TWO_PI 6.283185307179586476925286766559
#define DEG_TO_RAD 0.017453292519943295769236907684886
#define RAD_TO_DEG 57.295779513082320876798154814105
#define PENTIME 500
int minRPM = 20;
int maxRPM = 60;
int DEFAULTRPM = 30;
float STEPPERRADIUS = 42; //Radius of
int NRSTEPPERROT = 1600;
float AXIS_DISTANCE_X = 4700.0; //tenth of mm.
float AXIS_DISTANCE_Y = -2800.0;
float AXIS_DISTANCE_Z = 10.0;
int pendown = 0;
int penup = 90;
int echo = 0;
float curve_section = 1.0;
boolean UseAbsCoord=false;

EasyStepper stepper1(stepPinM1, dirPinM1, disPinM1);
EasyStepper stepper2(stepPinM2, dirPinM2, disPinM2);


struct vector_str {
  long lspos;
  long ldpos;
  long lcpos;
  int dir;
  long steps;
  long dist;
  float phase;
  long oldv;
  long newv;
  int speed;
};

vector_str s1, s2;
class axis {
public:
  axis() {
  }
  float fpos;
  float fhome;
  float fnewpos;
};


axis x = axis();
axis y = axis();

float step2mm;
long mm2step;

void setup()

{
  myservo.attach(SERVOPIN);
  pos = penup;
  myservo.write(pos);
  pinMode(RESETCFGPIN, INPUT);
  digitalWrite(RESETCFGPIN, HIGH);
  Serial.begin(57600);
  while (Serial.available()) Serial.read();

  if (digitalRead(RESETCFGPIN) == LOW) {
    savedefaults2eeprom();
#if DEBUG==1
    Serial.println(F(";Writting down"));
#endif
  }
  else {
    // at the moment do nothing.
    //  loaddefaultsfromeeprom();
#if DEBUG==1
    Serial.print((";Reading from eeprom: "));
    Serial.println(counter);
#endif
  }
  calculateProportions();
  setPolarparams();

  stepper2.swapdir();
  stepper1.disable();
  stepper2.disable();
  pinMode(ledPIN, OUTPUT);
  digitalWrite(ledPIN, LOW);
  Serial.println(F("READY"));
}

void loop() {

}

void loaddefaultsfromeeprom() {
  int epos = 0;
  EEPROM_readAnything(epos, STEPPERRADIUS);
  // continue here
}

void savedefaults2eeprom() {
  int epos = 0;
  EEPROM_writeAnything(epos, STEPPERRADIUS);
  epos += sizeof(STEPPERRADIUS);
  // continue here
}

void serialEvent() {
  checkInput();
}

void calculateProportions() {
  mm2step =  (TWO_PI * STEPPERRADIUS) / NRSTEPPERROT;
  step2mm =  NRSTEPPERROT / (TWO_PI * STEPPERRADIUS);
}
void  setPolarparams() {
  x.fhome = x.fpos = AXIS_DISTANCE_X / 2.0;
  y.fhome = y.fpos = AXIS_DISTANCE_Y;
  s1.lspos = s1.ldpos = s1.lcpos = computeA(x.fpos, y.fpos) * step2mm;
  s2.lspos = s2.ldpos = s2.lcpos = computeB(x.fpos, y.fpos) * step2mm;
  s2.dist = s1.dist = s1.steps = s2.steps = 0;
  s1.dir = s2.dir = 0;
  s1.phase = 1;
  s2.phase = 1;
  s2.speed = s1.speed = 60;
}

int returnCmdNumber(String str2parse) {
  char buff[10];

  str2parse.toCharArray(buff, 10);
  int Mcmd = 0;
  for (int i = 0; i < 10; i++) {
    if ( (buff[i] < 48) || (buff[i] > 57)) break;
    Mcmd = Mcmd * 10 + (buff[i] - 48);
  }
  return (Mcmd);
}

void parseAndExecuteCommand(String inputString ) {
  int REALRPM;
  char buff[10];
  int xstrpos;
  int ystrpos;
  int zstrpos;
  int fstrpos;
  int astrpos;
  int bstrpos;
  int istrpos;
  int jstrpos;
  int commastrpos;
  inputString.toUpperCase();
  if (inputString.startsWith(";", 0)) {
    if (echo == 1) {
      Serial.print(inputString);
      Serial.print("\t");
    }
    Serial.println(F("OK"));
    return;
  }
  commastrpos=inputString.indexOf(";");
  if (commastrpos > -1 ){
    inputString.remove(commastrpos);
  }
  else if (inputString.startsWith("M", 0)) { //set M command
    if (echo == 1) {
      Serial.print(inputString);
      Serial.print("\t");
    }
    switch (returnCmdNumber(inputString.substring(1))) {
    case 30:
      echo = 0;
      Serial.println(F("OK"));
      break;
    case 31:
      echo = 1;
      Serial.println(F("OK"));
      break;
    case 40: //pause for X millis.
      fstrpos = inputString.indexOf("T");
      inputString.substring(fstrpos + 1).toCharArray(buff, 10);
      delay(atol(buff));
      Serial.println(F("OK"));
      break;
    case 50: //pen up
      digitalWrite(ledPIN, LOW);
      pos = pendown;
      myservo.write(pos);
      delay(PENTIME);
      Serial.println(F("OK"));
      break;
    case 51: //pen down
      digitalWrite(ledPIN, HIGH);
      pos = penup;
      myservo.write(pos);
      delay(PENTIME);
      Serial.println(F("OK"));
      break;
    case 80: //pause
      // do nothing
      //Serial.println("");
      break;
    case 81: //continue
      Serial.println(F("OK"));
      break;
    case 84: //disable
      stepper1.disable();
      stepper2.disable();
      Serial.println(F("OK"));
      break;
    case 85: //enable
      stepper1.enable();
      stepper2.enable();
      Serial.println(F("OK"));
      break;
    case 90: //set home position to current position
      x.fhome = x.fpos;
      y.fhome = y.fpos;
      Serial.println(F("OK"));
      break;
    case 91: //set current position to home position
      x.fpos = x.fhome;
      y.fpos = y.fhome;
      Serial.println(F("OK"));
      break;
    case 100: // Listening?
      Serial.println(F("OK"));
      break;
    case 101: //set MINRPM
      fstrpos = inputString.indexOf("F");
      inputString.substring(fstrpos + 1).toCharArray(buff, 10);
      minRPM = atol(buff);
      Serial.println(F("OK"));
      break;
    case 102: //set MAXRPM
      fstrpos = inputString.indexOf("F");
      inputString.substring(fstrpos + 1).toCharArray(buff, 10);
      maxRPM = atol(buff);
      Serial.println(F("OK"));
      break;
    case 103: //set DEFAULTRPM
      fstrpos = inputString.indexOf("F");
      inputString.substring(fstrpos + 1).toCharArray(buff, 10);
      DEFAULTRPM = atol(buff);
      Serial.println(F("OK"));
      break;

    case 111: // set position
      xstrpos = inputString.indexOf("X");
      ystrpos = inputString.indexOf("Y");
      zstrpos = inputString.indexOf("Z");
      if (zstrpos > -1 ) {
        inputString.substring(zstrpos + 1).toCharArray(buff, 10);
        pos = atof(buff);
      } 
      else {
        zstrpos = inputString.length() + 1;
      }
      if (ystrpos > -1 ) {
        inputString.substring(ystrpos + 1, zstrpos - 1).toCharArray(buff, 10);
        y.fpos = atof(buff);
      } 
      else {
        ystrpos = zstrpos;
      }
      if (xstrpos > -1 ) {
        inputString.substring(xstrpos + 1, ystrpos - 1).toCharArray(buff, 10);
        x.fpos = atof(buff);
      }


      s1.lspos = s1.lcpos = computeA(x.fpos, y.fpos) * step2mm;
      s2.lspos = s2.lcpos = computeB(x.fpos, y.fpos) * step2mm;

      break;
    case 112: //report position
      Serial.print(F(";X: "));
      Serial.print(x.fpos);
      Serial.print(F(" Y: "));
      Serial.print(y.fpos);
      Serial.print(F(" Z: "));
      Serial.println(pos);
      Serial.print(F(";A: "));
      Serial.print(s1.lcpos);
      Serial.print(F(" B: "));
      Serial.println(s2.lcpos);
      Serial.print(F(";F: "));
      Serial.println(DEFAULTRPM);
      Serial.print(F("ABS: "));
      Serial.println((UseAbsCoord==true?F("True"):F("False")));
      Serial.println(F("OK"));
      break;
    case 113:
      astrpos = inputString.indexOf("A");
      bstrpos = inputString.indexOf("B");
      if (astrpos > 0) {
        stepper1.swapdir();
      }
      if (bstrpos > 0) {
        stepper2.swapdir();
      }
      Serial.println(F("OK"));
      break;
    case 114: // save to EEPROM
      break;
    case 115: // load from EEPROM
      break;
    case 116: // GO HOME without altering Z pos.
      gotto(x.fhome - x.fpos, y.fhome - y.fpos, pos);
      Serial.println(F("OK"));
      break;
    case 120: // Request explicit order to enable/disable steppers.
      break;
    case 121: // set implicit order to enable/disable steppers.
      break;
    case 130: // Request explicit positioning of Z
      break;
    case 131: // set auto-raise z after T seconds
      break;
    }

  }
  else if (inputString.startsWith("G", 0)) {
    if (echo == 1) {
      Serial.print(inputString);
      Serial.print("\t");
    }
    switch (returnCmdNumber(inputString.substring(1))) {
    case 0: //move as fast as possible
      xstrpos = inputString.indexOf("X");
      ystrpos = inputString.indexOf("Y");
      zstrpos = inputString.indexOf("Z");
      if (zstrpos > -1 ) {
        inputString.substring(zstrpos + 1).toCharArray(buff, 10);
        pos = atof(buff);
      } 
      else {
        zstrpos = inputString.length() + 1;
      }
      if (ystrpos > -1 ) {
        inputString.substring(ystrpos + 1, zstrpos - 1).toCharArray(buff, 10);
        y.fnewpos = atof(buff);
      } 
      else {
        y.fnewpos = (UseAbsCoord==true?y.fpos:0.0);
        ystrpos = zstrpos;
      }
      if (xstrpos > -1 ) {
        inputString.substring(xstrpos + 1, ystrpos - 1).toCharArray(buff, 10);
        x.fnewpos = atof(buff);
      } 
      else {
        x.fnewpos = (UseAbsCoord==true?x.fpos:0.0);
      }
      REALRPM = DEFAULTRPM;
      DEFAULTRPM = maxRPM;
      if(UseAbsCoord==true){
        gotto(x.fpos,y.fpos, pos);
        gotto(x.fnewpos, y.fpos, pos);
        gotto(x.fpos, y.fnewpos, pos);

      }
      else{
        gotto(0.0, 0.0, pos);
        gotto(x.fnewpos, 0, pos);
        gotto(0, y.fnewpos, pos); 
      }
      DEFAULTRPM = REALRPM;
      Serial.println(F("OK"));
      break;
    case 1: // G1 X<steps> Y<steps>
      xstrpos = inputString.indexOf("X");
      ystrpos = inputString.indexOf("Y");
      zstrpos = inputString.indexOf("Z");
      fstrpos = inputString.indexOf("F");
      if (fstrpos > -1 ) {
        inputString.substring(fstrpos + 1).toCharArray(buff, 10);
        DEFAULTRPM = atol(buff);
      }
      else{
        fstrpos = inputString.length() + 1;
      }
      if (zstrpos > -1 ) {
        inputString.substring(zstrpos + 1,fstrpos -1).toCharArray(buff, 10);
        pos = atof(buff);
      } 
      else {
        zstrpos = fstrpos;
      }
      if (ystrpos > -1 ) {
        inputString.substring(ystrpos + 1, zstrpos - 1).toCharArray(buff, 10);
        y.fnewpos = atof(buff);
      } 
      else {
        y.fnewpos = (UseAbsCoord==true?y.fpos:0.0);
        ystrpos = zstrpos;
      }
      if (xstrpos > -1 ) {
        inputString.substring(xstrpos + 1, ystrpos - 1).toCharArray(buff, 10);
        x.fnewpos = atof(buff);
      } 
      else {
        x.fnewpos = (UseAbsCoord==true?x.fpos:0.0);
      }
      gotto(x.fnewpos, y.fnewpos, pos);
      Serial.println(F("OK"));
      break;
    case 2: //ARC
      xstrpos = inputString.indexOf("X");
      ystrpos = inputString.indexOf("Y");
      istrpos = inputString.indexOf("I");
      jstrpos = inputString.indexOf("J");
      fstrpos = inputString.indexOf("F");
      if (fstrpos > -1 ) {
        inputString.substring(fstrpos + 1).toCharArray(buff, 10);
        DEFAULTRPM = atol(buff);
      }
      else{
        fstrpos = inputString.length() + 1;
      }
      if (xstrpos > -1 && ystrpos > -1 && istrpos > -1 && jstrpos > -1) {
        float jfnewpos, ifnewpos;
        inputString.substring(jstrpos + 1,fstrpos -1).toCharArray(buff, 10);
        jfnewpos = atof(buff);
        inputString.substring(istrpos + 1, jstrpos - 1).toCharArray(buff, 10);
        ifnewpos = atof(buff);
        inputString.substring(ystrpos + 1, istrpos - 1).toCharArray(buff, 10);
        y.fnewpos = atof(buff);
        inputString.substring(xstrpos + 1, ystrpos - 1).toCharArray(buff, 10);
        x.fnewpos = atof(buff);
        arcgotto(CW, x.fnewpos, y.fnewpos, ifnewpos, jfnewpos);
        Serial.println(F("OK"));
      } 
      else {
        Serial.println(F("ERR"));
      }
      break;
    case 3: //ARC
      xstrpos = inputString.indexOf("X");
      ystrpos = inputString.indexOf("Y");
      istrpos = inputString.indexOf("I");
      jstrpos = inputString.indexOf("J");
      fstrpos = inputString.indexOf("F");
      if (fstrpos > -1 ) {
        inputString.substring(fstrpos + 1).toCharArray(buff, 10);
        DEFAULTRPM = atol(buff);
      }
      else{
        fstrpos = inputString.length() + 1;
      }
      if (xstrpos > -1 && ystrpos > -1 && istrpos > -1 && jstrpos > -1) {
        float jfnewpos, ifnewpos;
        inputString.substring(jstrpos + 1,fstrpos -1).toCharArray(buff, 10);
        jfnewpos = atof(buff);
        inputString.substring(istrpos + 1, jstrpos - 1).toCharArray(buff, 10);
        ifnewpos = atof(buff);
        inputString.substring(ystrpos + 1, istrpos - 1).toCharArray(buff, 10);
        y.fnewpos = atof(buff);
        inputString.substring(xstrpos + 1, ystrpos - 1).toCharArray(buff, 10);
        x.fnewpos = atof(buff);
        arcgotto(CCW, x.fnewpos, y.fnewpos, ifnewpos, jfnewpos);
        Serial.println(F("OK"));
      } 
      else {
        Serial.println(F("ERR"));
      }
      break;
    case 20: //  set units to inches
      Serial.println(F("OK"));
      break;
    case 21: //  set units to millis
      Serial.println(F("OK"));
      break;
    case 28: //  Go Home
      if (UseAbsCoord==true){
        gotto(x.fhome, y.fhome, 90);
      }
      else{
        gotto(x.fhome - x.fpos, y.fhome - y.fpos, 90);
      }
      Serial.println(F("OK"));
      break;
    case 90: //  use absolute coordinates
      UseAbsCoord=true;
      Serial.println(F("OK"));
      break;
    case 91: //  use relative coordinates
      UseAbsCoord=false;
      Serial.println(F("OK"));
      break;
    }
  }
  else {
    // Unrecognized command
    Serial.println("ERROR Unrecognized Command");
  }

}

/* This routine checks for any input waiting on the serial line. If any is
 * available it is read in and added to a 128 character buffer. It sends back
 * an error should the buffer overflow, and starts overwriting the buffer
 * at that point. It only reads one character per call. If it receives a
 * newline character is then runs the parseAndExecuteCommand() routine.
 */
void checkInput() {
  int inbyte;
  static char incomingBuffer[128];
  static char bufPosition = 0;

  if (Serial.available() > 0) {
    // Read only one character per call
    inbyte = Serial.read();
    if (inbyte == 10) {
      // Newline detected
      incomingBuffer[bufPosition] = '\0'; // NULL terminate the string
      bufPosition = 0; // Prepare for next command

      // Supply a separate routine for parsing the command. This will
      // vary depending on the task.
      parseAndExecuteCommand(String(incomingBuffer));
    }
    else {
      incomingBuffer[bufPosition] = (char)inbyte;
      bufPosition++;
      if (bufPosition == 128) {
        Serial.println("ERROR Command Overflow");
        bufPosition = 0;
      }
    }
  }
}


long computeA(float x, float y) {
  return sqrt(x * x + y * y);// first hypotenusa
}

long computeB(float x, float y) {
  long distanceX = AXIS_DISTANCE_X - x;
  return sqrt((distanceX * distanceX) + y * y); //second hypotenusa
}

void gotto(float xdiff, float ydiff, int zpos) {
  if (UseAbsCoord==true){
    xdiff -=x.fpos;
    ydiff -=y.fpos;
  }
  s1.ldpos = computeA(x.fpos + xdiff, y.fpos + ydiff) * step2mm;
  s2.ldpos = computeB(x.fpos + xdiff, y.fpos + ydiff) * step2mm;

  myservo.write(zpos);
  getthere();
  s1.lspos = s1.lcpos = s1.ldpos;
  s2.lspos = s2.lcpos = s2.ldpos;
  y.fpos += ydiff;
  x.fpos += xdiff;
}

void arcgotto(boolean dir, float xdiff, float ydiff, float idiff, float jdiff) {
  boolean TempRelCoord=UseAbsCoord;
  if (UseAbsCoord==true){
    xdiff -=x.fpos;
    ydiff -=y.fpos;
    idiff -=x.fpos;
    jdiff -=y.fpos;
    UseAbsCoord=false;
  }
  float angleA, angleB, angle, radius, arclength, aX, aY, bX, bY;
  aX =  -1 * idiff ;
  aY =  -1 * jdiff;
  bX = (xdiff - idiff) ;
  bY = (ydiff - jdiff);

  if (dir == CW) { // Clockwise
    angleA = atan2(bY, bX);
    angleB = atan2(aY, aX);
  } 
  else { // Counterclockwise
    angleA = atan2(aY, aX);
    angleB = atan2(bY, bX);
  }

  // Make sure angleB is always greater than angleA
  // and if not add 2PI so that it is (this also takes
  // care of the special case of angleA == angleB,
  // ie we want a complete circle)
  if (angleB <= angleA) angleB += 2 * M_PI;
  angle = angleB - angleA;

  radius = sqrt(aX * aX + aY * aY);
  arclength = radius * angle;
  int steps, s, step;
  steps = (int) ceil(arclength / curve_section);

  if (dir == CW) {
    step = steps - 1;
  } 
  else {
    step = 1;
  }

  float lastPointx = x.fpos;
  float lastPointy = y.fpos;
  float OrigDestx = x.fpos + xdiff;
  float OrigDesty = y.fpos + ydiff ;
  float nextPointx;
  float nextPointy;
  float distTraveled = 0;
  for (s = 1; s <= steps; s++) {
    step = (dir == CW ) ?  steps - s : s; // Work backwards for CW
    nextPointx = lastPointx + idiff + radius * cos(angleA + angle * ((float) step / steps));
    nextPointy = lastPointy + jdiff + radius * sin(angleA + angle * ((float) step / steps));
    gotto(nextPointx - x.fpos, nextPointy - y.fpos, pos);
  }
  gotto(OrigDestx - x.fpos, OrigDesty - y.fpos, pos);
  UseAbsCoord=TempRelCoord;
}


unsigned long rpm2delay(long rpm) {
  //return (500);
  return (37500 / rpm);
}

void getthere() {
  unsigned long t;
  s1.dist = s1.steps = abs(s1.ldpos - s1.lspos);
  s2.dist = s2.steps = abs(s2.ldpos - s2.lspos);
  s1.dir = (s1.ldpos > s1.lspos ? FORWARD : BACKWARD);
  s2.dir = (s2.ldpos > s2.lspos ? FORWARD : BACKWARD);

  t = max(s1.steps, s2.steps);
  if (t == 0) return;
  s1.phase = float(s1.steps) / float(t);
  s2.phase = float(s2.steps) / float(t);
  s1.oldv = s1.newv = 0.0;
  s2.oldv = s2.newv = 0.0;

  stepper1.dir(s1.dir);
  stepper2.dir(s2.dir);
  for (int i = 1; i < t + 1; i++) {
    if (s1.steps > 0) {
      if (s1.phase > 0.0) s1.newv = int( i * s1.phase + 0.5);
      if (s1.newv - s1.oldv > 0) {
        stepper1.onestep();
        s1.steps--;
      }
    }
    if (s2.steps > 0) {
      if (s2.phase > 0.0) s2.newv = int( i * s2.phase + 0.5);
      if (s2.newv - s2.oldv > 0) {
        stepper2.onestep();
        s2.steps--;
      }
    }
    //    delayMicroseconds(cruze(t,i));
    delayMicroseconds(rpm2delay(DEFAULTRPM));
    s1.oldv = s1.newv;
    s2.oldv = s2.newv;
  }
}



unsigned long cruze(long t, long i) {
  return (rpm2delay(map(sin(PI * (float(i) / float(t))), -1.0, 1.0, minRPM, DEFAULTRPM)));
}



















