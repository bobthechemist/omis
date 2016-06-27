#include "Pump.h"
#include "CommandParser.h"

// Using #define saves a few bytes of dynamic memory, and these values should not change during the program
#define P1 12
#define P2 11
#define P3 10
#define P4 9
#define MA 15
#define TPM 0.787
#define LVR 13.0
#define STEPS 513

CommandParser cp;
Pump pump1(STEPS, P1, P2, P3, P4, MA, TPM, LVR);

void setup() {
  // Set up serial communications
  Serial.begin(9600);
  while(!Serial) {
    ; //Wait for connect
  }
  Serial.println("Syringe pump communications established");

  // Set an initial speed
  pump1.setSpeed(25);
  
}

void loop() {
  // the validate() function of the CommandParser checks to see if a command is
  //   ready for parsing and that the user input follows the basic structure of a command.
  if(cp.validate()){
    cp.parse();
    pump1.operate(cp.operation, cp.argument);
    cp.refresh();
    
  }

}

// Using serial events for capturing user requests
void serialEvent() {
  cp.read();
}

