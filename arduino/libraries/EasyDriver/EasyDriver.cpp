// EasyMotor version 1.0
// by Meir Michanie
// meirm@riunx.com

#include <EasyDriver.h>

EasyMotor::EasyMotor(int dirpin,int pwmpin)
{
	_dirpin=dirpin;
	_pwmpin=pwmpin;
	pinMode(dirpin,OUTPUT);
	pinMode(dirpin,OUTPUT);
	digitalWrite(dirpin,LOW);
	digitalWrite(pwmpin,LOW);
	_swapdir=1;
	_speed=0;
	_moving=0;
	
}

void EasyMotor::swapdir()
{
	_swapdir=(_swapdir==1?-1:1);
}

void EasyMotor::SetSpeed(int pwm)
{
	_speed=abs(pwm);
	if (_moving == 1) this->Drive();
}

void EasyMotor::Drive(int pwm)
{
	pwm*=_swapdir;
	_speed=abs(pwm);
	if (pwm < 0){
		digitalWrite(this->_dirpin,LOW);
	}else if(pwm >0){
		digitalWrite(this->_dirpin,HIGH);
	}
	this->Drive();
}

void EasyMotor::Stop()
{
	digitalWrite(this->_pwmpin,0);
	_moving=0;
}
void EasyMotor::Drive()
{
	_moving=1;
	digitalWrite(this->_pwmpin,_speed);
}

//######################################################3

EasyStepper::EasyStepper(int steppin,int dirpin, int dispin)
{
	this->_dirpin=dirpin;
	this->_steppin=steppin;
	this->_dispin=dispin;
	pinMode(dirpin,OUTPUT);
	pinMode(steppin,OUTPUT);
	pinMode(dispin,OUTPUT);
	digitalWrite(dirpin,LOW);
	digitalWrite(steppin,LOW);
	digitalWrite(dispin,HIGH);
	this->_swapdir=0;
	this->pulse=0;
	this->_dir=0;
	
}

void EasyStepper::swapdir()
{
	this->_swapdir=1-this->_swapdir;
}


void EasyStepper::enable()
{
	digitalWrite(_dispin,LOW);
	
}

void EasyStepper::disable()
{
	digitalWrite(_dispin,HIGH);
}

void EasyStepper::dir(int direction){
	this->_dir=direction;
digitalWrite(_dirpin,abs(_swapdir - _dir));
}

int EasyStepper::dir(){
	return this->_dir;
}


void EasyStepper::step(int nrsteps,int direction,int timewait){
	this->dir(direction);
	for(int i=0; i<nrsteps;i++){
	this->halfstep();
	delayMicroseconds(20);
	this->halfstep();
	delayMicroseconds(timewait - 20);
	}
}
void EasyStepper::onestep(){
	this->pulse=0;
	this->halfstep();
	delayMicroseconds(20);
	this->halfstep();
}

void EasyStepper::halfstep(){
	this->pulse= 1- this->pulse;
	digitalWrite(_steppin,pulse);
}

