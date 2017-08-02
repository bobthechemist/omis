#include "Pump.h"
#include "CommandParser.h"

#define NPUMPS 2

/* PUMP 0 */
#define P01 12
#define P02 11
#define P03 10
#define P04 9
#define EN0 13
#define MA0 15
#define TPM0 0.787
#define LVR0 13.0
#define STEPS0 513

/* PUMP 1 */
#define P11 8
#define P12 7
#define P13 6
#define P14 5
#define EN1 4
#define MA1 15
#define TPM1 0.787
#define LVR1 13.0
#define STEPS1 513

#define VERSION 0.3

// Shield interface (one pushbutton input, two LED outputs)
//const byte REDLED = 8;
//const byte BUTTON = A0;

CommandParser cp;

Pump pump[] { 
  Pump(STEPS1, P11, P12, P13, P14, EN1, MA1, TPM1, LVR1),
  Pump(STEPS0, P01, P02, P03, P04, EN0, MA0, TPM0, LVR0)
};


// Interrupt Service Routine (ISR)
/*
void switchPressed ()
{
  if (digitalRead (BUTTON) == HIGH)
    digitalWrite (REDLED, LOW);
  else
    digitalWrite (REDLED, HIGH);
}  // end of switchPressed
*/

void setup() {
  // Set up serial communications
  Serial.begin(9600);
  while(!Serial) {
    ; //Wait for connect
  }
  Serial.println("Syringe pump communications established");
  Serial.print("This is version ");
  Serial.print(VERSION);
  Serial.println(".");

  // Shield interface and interrupt **INTERFERES WITH 2ND H-BRIDGE**
  //pinMode (REDLED, OUTPUT);  // so we can update the LED
  //digitalWrite (BUTTON, HIGH);  // internal pull-up resistor
  //attachInterrupt (0, switchPressed, CHANGE);  // attach interrupt handler

  // Set the initial pump as pump(0)
  cp.whichPump = 0;
  Serial.println("Controlling pump #0");

  // Set an initial speed
  for (int i = 0; i < NPUMPS; i++ ) {
    pump[i].setSpeed(25);
  }

}

void loop() {
  // the validate() function of the CommandParser checks to see if a command is
  //   ready for parsing and that the user input follows the basic structure of a command.
  if(cp.validate()){
    cp.parse();
    if(cp.operation == "sp") {
      if ( (cp.argument.toInt() < 0) || (cp.argument.toInt() >= NPUMPS) ) {
        Serial.println("Error! Default to pump #0");
        cp.whichPump = 0;
      }
      else {
        cp.whichPump = cp.argument.toInt();
        Serial.println("Controlling pump #" + cp.argument);
      }
    }
    else {
      pump[cp.whichPump].operate(cp.operation, cp.argument);

    }
    cp.refresh();
    
  }
  // Always check if a step should be made
  for (int i = 0; i < NPUMPS; i++ ) {
    pump[i].tryStep();
  }

}

// Using serial events for capturing user requests
void serialEvent() {
  cp.read();
}

