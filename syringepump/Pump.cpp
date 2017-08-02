/*
 * Pump.cpp - Stepper library for syringe pump, based off:
 * Stepper.cpp - Stepper library for Wiring/Arduino - Version 1.1.0
 * 
 * Modifications:
 * - step_delay is now type float allowing for more precise speed selections
 * - setSpeed accepts type float per above
 * - added pump data to constructors (mechanicalAdvantage, threadsPerMillimeter, syringLinearVolumeRatio)
 * - added syringe math (e.g. calculate number of steps needed to deliver a given volume.)
 * - added command structure
 * - changed `step` to accept long type
 * - removed `step` and reaplced it with `tryStep`, a nonblocking version that accommodates moving multiple motors simultaneously
 */

/* TODO:
 *  - Noticed that changes might require TWO uploads in order to take effect.  Not sure why or under what conditions.
 */
 
#include "Arduino.h"
#include "Pump.h"

/*
 * two-wire constructor.
 * Sets which wires should control the motor.
 */
Pump::Pump(int number_of_steps, int motor_pin_1, int motor_pin_2, int enable_pin,
            float mechanicalAdvantage, float threadsPerMillimeter, 
            float syringeLinearVolumeRatio)
{
  this->step_number = 0;    // which step the motor is on
  this->direction = 0;      // motor direction
  this->last_step_time = 0; // time stamp in us of the last step taken
  this->number_of_steps = number_of_steps; // total number of steps for this motor

  // Arduino pins for the motor control connection:
  this->motor_pin_1 = motor_pin_1;
  this->motor_pin_2 = motor_pin_2;

  // setup the pins on the microcontroller:
  pinMode(this->motor_pin_1, OUTPUT);
  pinMode(this->motor_pin_2, OUTPUT);

  // When there are only 2 pins, set the others to 0:
  this->motor_pin_3 = 0;
  this->motor_pin_4 = 0;
  this->motor_pin_5 = 0;

  // pin_count is used by the stepMotor() method:
  this->pin_count = 2;

  // setup enable pin and enable the L293D
  this->enable_pin = enable_pin;
  pinMode(this->enable_pin, OUTPUT);
  digitalWrite(this->enable_pin, HIGH);

  // setup pump data
  this->mechanicalAdvantage = mechanicalAdvantage;
  this->threadsPerMillimeter = threadsPerMillimeter;
  this->syringeLinearVolumeRatio = syringeLinearVolumeRatio;
}


/*
 *   constructor for four-pin version
 *   Sets which wires should control the motor.
 */
Pump::Pump(int number_of_steps, int motor_pin_1, int motor_pin_2,
            int motor_pin_3, int motor_pin_4, int enable_pin, float mechanicalAdvantage, 
            float threadsPerMillimeter, float syringeLinearVolumeRatio)
{
  this->step_number = 0;    // which step the motor is on
  this->direction = 0;      // motor direction
  this->last_step_time = 0; // time stamp in us of the last step taken
  this->number_of_steps = number_of_steps; // total number of steps for this motor

  // Arduino pins for the motor control connection:
  this->motor_pin_1 = motor_pin_1;
  this->motor_pin_2 = motor_pin_2;
  this->motor_pin_3 = motor_pin_3;
  this->motor_pin_4 = motor_pin_4;

  // setup the pins on the microcontroller:
  pinMode(this->motor_pin_1, OUTPUT);
  pinMode(this->motor_pin_2, OUTPUT);
  pinMode(this->motor_pin_3, OUTPUT);
  pinMode(this->motor_pin_4, OUTPUT);

  // When there are 4 pins, set the others to 0:
  this->motor_pin_5 = 0;

  // pin_count is used by the stepMotor() method:
  this->pin_count = 4;

  // setup enable pin and enable the L293D
  this->enable_pin = enable_pin;
  pinMode(this->enable_pin, OUTPUT);
  digitalWrite(this->enable_pin, HIGH);
  
  // setup pump data
  this->mechanicalAdvantage = mechanicalAdvantage;
  this->threadsPerMillimeter = threadsPerMillimeter;
  this->syringeLinearVolumeRatio = syringeLinearVolumeRatio;

  
}

/*
 *   constructor for five phase motor with five wires
 *   Sets which wires should control the motor.
 */
Pump::Pump(int number_of_steps, int motor_pin_1, int motor_pin_2,
            int motor_pin_3, int motor_pin_4, int motor_pin_5,int enable_pin,
            float mechanicalAdvantage, float threadsPerMillimeter, 
            float syringeLinearVolumeRatio)
{
  this->step_number = 0;    // which step the motor is on
  this->direction = 0;      // motor direction
  this->last_step_time = 0; // time stamp in us of the last step taken
  this->number_of_steps = number_of_steps; // total number of steps for this motor

  // Arduino pins for the motor control connection:
  this->motor_pin_1 = motor_pin_1;
  this->motor_pin_2 = motor_pin_2;
  this->motor_pin_3 = motor_pin_3;
  this->motor_pin_4 = motor_pin_4;
  this->motor_pin_5 = motor_pin_5;

  // setup the pins on the microcontroller:
  pinMode(this->motor_pin_1, OUTPUT);
  pinMode(this->motor_pin_2, OUTPUT);
  pinMode(this->motor_pin_3, OUTPUT);
  pinMode(this->motor_pin_4, OUTPUT);
  pinMode(this->motor_pin_5, OUTPUT);

  // pin_count is used by the stepMotor() method:
  this->pin_count = 5;

  // setup enable pin and enable the L293D
  this->enable_pin = enable_pin;
  pinMode(this->enable_pin, OUTPUT);
  digitalWrite(this->enable_pin, HIGH);
  
  // setup pump data
  this->mechanicalAdvantage = mechanicalAdvantage;
  this->threadsPerMillimeter = threadsPerMillimeter;
  this->syringeLinearVolumeRatio = syringeLinearVolumeRatio;  
}

/*
 * Sets the speed in revs per minute
 */
void Pump::setSpeed(float whatSpeed)
{
  this->step_delay = 60.0 * 1000.0 * 1000.0 / 
    this->number_of_steps / constrain(whatSpeed,this->minRPM,this->maxRPM);
}

/*
 * Adds steps to the step buffer
 */
int Pump::addSteps(int numSteps) {
  /* Only add steps if the buffer is empty */
  if (this -> stepBuffer == 0) {
    this->stepBuffer = numSteps;
    // Assign direction
    (numSteps >= 0) ? this->direction = 1 : this->direction = -1 ;
    return 1;
  }
  return 0; // Failed to add steps
}

/*
 * Checks to see if a step should be made and does it.
 */
void Pump::tryStep()
{
  // Return if there are no steps to take
  if ( this->stepBuffer == 0) {
      // unlock (de-energize motor if necessary
    if (1) unlock(); 
    return; 
  }

  // decrement the number of steps and move one step:
 
  unsigned long now = micros();
  // move only if the appropriate delay has passed:
  if (now - this->last_step_time >= this->step_delay)
  {
    // get the timeStamp of when you stepped:
    this->last_step_time = now;
    // increment or decrement the step number,
    // depending on direction:
    if (this->direction == 1)
    {
     this->step_number++;
      if (this->step_number == this->number_of_steps) {
        this->step_number = 0;
      }
    }
    else
    {
      if (this->step_number == 0) {
        this->step_number = this->number_of_steps;
      }
      this->step_number--;
    }
    // decrement the steps left:
    this->stepBuffer -= this->direction;
    
    // step the motor to step number 0, 1, ..., {3 or 10}
    if (this->pin_count == 5)
      stepMotor(this->step_number % 10);
    else
      stepMotor(this->step_number % 4);
  }


}

/*
 * Moves the motor forward or backwards.
 */
void Pump::stepMotor(int thisStep)
{
  if (this->pin_count == 2) {
    switch (thisStep) {
      case 0:  // 01
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
      break;
      case 1:  // 11
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, HIGH);
      break;
      case 2:  // 10
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
      break;
      case 3:  // 00
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, LOW);
      break;
    }
  }
  if (this->pin_count == 4) {
    switch (thisStep) {
      case 0:  // 1010
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, LOW);
      break;
      case 1:  // 0110
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, LOW);
      break;
      case 2:  //0101
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, HIGH);
      break;
      case 3:  //1001
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, HIGH);
      break;
    }
  }

  if (this->pin_count == 5) {
    switch (thisStep) {
      case 0:  // 01101
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, LOW);
        digitalWrite(motor_pin_5, HIGH);
        break;
      case 1:  // 01001
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, LOW);
        digitalWrite(motor_pin_5, HIGH);
        break;
      case 2:  // 01011
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, HIGH);
        digitalWrite(motor_pin_5, HIGH);
        break;
      case 3:  // 01010
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, HIGH);
        digitalWrite(motor_pin_5, LOW);
        break;
      case 4:  // 11010
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, HIGH);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, HIGH);
        digitalWrite(motor_pin_5, LOW);
        break;
      case 5:  // 10010
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, LOW);
        digitalWrite(motor_pin_4, HIGH);
        digitalWrite(motor_pin_5, LOW);
        break;
      case 6:  // 10110
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, HIGH);
        digitalWrite(motor_pin_5, LOW);
        break;
      case 7:  // 10100
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, LOW);
        digitalWrite(motor_pin_5, LOW);
        break;
      case 8:  // 10101
        digitalWrite(motor_pin_1, HIGH);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, LOW);
        digitalWrite(motor_pin_5, HIGH);
        break;
      case 9:  // 00101
        digitalWrite(motor_pin_1, LOW);
        digitalWrite(motor_pin_2, LOW);
        digitalWrite(motor_pin_3, HIGH);
        digitalWrite(motor_pin_4, LOW);
        digitalWrite(motor_pin_5, HIGH);
        break;
    }
  }
}

/*
  version() returns the version of the library:
*/
int Pump::version(void)
{
  return 2;
}

// Debugging
float Pump::debug(void)
{
  return this->step_delay;
}

// find RPM for a given flow rate;
float Pump::FRtoRPM(float flowRate)
{
  return flowRate * this->syringeLinearVolumeRatio / 1000.0 * 
    this->threadsPerMillimeter * this->mechanicalAdvantage;
}

// find flow rate fora given RPM
float Pump::RPMtoFR(float rpm)
{
  return rpm / this->mechanicalAdvantage / this->threadsPerMillimeter * 
    1000.0 / this->syringeLinearVolumeRatio;
}

// find # steps to deliver desired volume (in uL)
float Pump::VOLtoSTEPS(float volume)
{
  return volume / 1000.0 * this-> syringeLinearVolumeRatio * this->threadsPerMillimeter * 
    this->mechanicalAdvantage * this->number_of_steps;
}

// find # steps to move plunger <distance> millimeters 
float Pump::DISTtoSTEPS(float distance) 
{
  return distance * this->threadsPerMillimeter * this->mechanicalAdvantage * this->number_of_steps;
}

// release all coils to minimize current draw
void Pump::unlock(void)
{
  digitalWrite(motor_pin_1, LOW);
  digitalWrite(motor_pin_2, LOW);
  digitalWrite(motor_pin_3, LOW);
  digitalWrite(motor_pin_4, LOW);
  this->step_number = 0;  
}

// Enables/disables L293D
void Pump::enable(int val)
{
  // Enable L293D on 1, off for 0 or invalid value
  if (val == 1) {
    digitalWrite(enable_pin, HIGH);
  }
  else {
    digitalWrite(enable_pin, LOW);
  }
  
}

