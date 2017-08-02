/*
 * Pump.h - Stepper library for syringe pump.  Modified version of 
 * Stepper.h - Stepper library for Wiring/Arduino - Version 1.1.0
 *
 */

// ensure this library description is only included once
#ifndef Pump_h
#define Pump_h

/* Made unlocking no longer optional */ 
//#define UNLOCK 1 // 1 unlock motor following a movement


// library interface description
class Pump {
  public:
    // constructors:

    Pump(int number_of_steps, int motor_pin_1, int motor_pin_2,
                              int enable_pin,
                              float mechanicalAdvantage, float threadsPerMillimeter,
                              float syringeLinearVolumeRatio);
    Pump(int number_of_steps, int motor_pin_1, int motor_pin_2,
                              int motor_pin_3, int motor_pin_4,
                              int enable_pin,
                              float mechanicalAdvantage, float threadsPerMillimeter,
                              float syringeLinearVolumeRatio);                                 
    Pump(int number_of_steps, int motor_pin_1, int motor_pin_2,
                              int motor_pin_3, int motor_pin_4,
                              int motor_pin_5, int enable_pin,
                              float mechanicalAdvantage, float threadsPerMillimeter,
                              float syringeLinearVolumeRatio);                                 
    
    void setSpeed(float whatSpeed); // speed setter method:
    int version(void);
    float debug(void);

    // Syringe math
    float FRtoRPM(float flowRate); // find RPM for a given flow rate (in uL/min)
    float VOLtoSTEPS(float volume); // find # steps to deliver desired volume (in uL)
    float DISTtoSTEPS(float distance); // find # steps to move plunger <distance> millimeters
    float RPMtoFR(float rpm); // convert (motor) RPM to a flow rate in uL/min

    // Operate receives ops and args (typically from the command parser)
    int operate(String op, String arg);

    /* TODO: make private and add functions to access */
    // Probably private, but easier to make these public for the moment
    float minRPM = 1;
    float maxRPM = 40;

    /* TODO: make stepBuffer and addSteps private */
    // Non-blocking motor movement
    int stepBuffer = 0; // Number of steps that motor should take, should be private
    void tryStep(void); // To place in loop to see if step should be taken
    int addSteps(int); // Add steps to the step buffer, should be private

    // release stepper coils
    void unlock(void);
    // Toggle L293D on/off
    void enable(int val);
    
  private:
    void stepMotor(int this_step);
    int number_of_steps;      // total number of steps this motor can take
    int direction;            // Direction of rotation
    float step_delay; // delay between steps, in ms, based on speed
    int pin_count;            // how many pins are in use.
    int step_number;          // which step the motor is on

    // motor pin numbers:
    int motor_pin_1;
    int motor_pin_2;
    int motor_pin_3;
    int motor_pin_4;
    int motor_pin_5;          // Only 5 phase motor

    // Enable pin for L293D 
    int enable_pin;

    unsigned long last_step_time; // time stamp in us of when the last step was taken

    float mechanicalAdvantage; // Gear ratio 
    float threadsPerMillimeter; // of lead screw
    float syringeLinearVolumeRatio; // 
};

#endif


