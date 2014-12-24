#ifndef _EasyDriver_H
#define _EasyDriver_H
#include "Arduino.h"

#define PI 3.1415926535897932384626433832795
#define HALF_PI 1.5707963267948966192313216916398
#define TWO_PI 6.283185307179586476925286766559
#define DEG_TO_RAD 0.017453292519943295769236907684886
#define RAD_TO_DEG 57.295779513082320876798154814105
#define FORWARD 1
#define BACKWARD 0
class EasyMotor{
public:
  EasyMotor(int dirpin,int pwmpin);
  void Drive(int pwm);
  void Drive();
  void Stop();
  void swapdir();
  void SetSpeed(int pwm);
protected:
	int _dirpin;
	int _pwmpin;
 	int _maxspeed; 
	int _swapdir;
	int _speed;
	int _moving;
};

class EasyStepper{
public:
  EasyStepper(int steppin,int dirpin,int dispin);
  void step(int nrsteps,int direction,int timewait);
  void onestep();
  void enable();
  void disable();
  void halfstep();
  void swapdir();
  void dir(int direction);
  int dir();
//protected:
	int _dirpin;
	int _steppin;
	int _dispin;
 	int _swapdir;
 	int _dir;
	int pulse;
};

#endif /* not defined _EasyDriver_H */

