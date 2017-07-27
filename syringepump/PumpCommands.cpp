#include "Arduino.h"
#include "Pump.h"

int Pump::operate(String op, String arg){
  if      ( op == "ss" ) {
    float tmp = constrain(arg.toFloat(),this->minRPM, this->maxRPM);
    Serial.println("Setting RPMs to " + String(tmp) + ".");
    this->setSpeed(tmp);
  }
  else if ( op == "mv" ) {
    if(this->addSteps(arg.toInt())) {
      Serial.println("Moving " + arg + " steps.");
    }
  }
  else if ( op == "tu" ) {
    if(this->addSteps( int(arg.toFloat() * this->number_of_steps ))) {
      Serial.println("Performing " + arg + " turn(s).");
    }
  }
  else if ( op == "sf" ) {
    /* Add error msg if contrains are enforced on user input */
    float tmp = constrain(
      this->FRtoRPM(arg.toFloat()),
      this->minRPM,
      this->maxRPM);
    Serial.println("Flow rate: " + arg + " uL/min by setting RPMs to " + String(tmp) + ".");
    this->setSpeed(tmp);
  }
  else if ( op == "de" ) {
    if(this->addSteps( VOLtoSTEPS(arg.toFloat()))) {
      Serial.println("Delivering " + arg + " uL.");
    }
  }
  else if (op == "go") {
    Serial.println("I don't do this yet");
    //Serial.println("Starting program");
    //this->program();
    //Serial.println("Finished program");
  }
  else if (op == "un") {
    Serial.println("Unlocking motor");
    this->unlock();
  }
  else if (op == "en") {
    Serial.println("Enable command.");
    this->enable(arg.toInt());
  }
  else {
    Serial.println("Invalid command");
    return 0;
  }
  return 1;
}

// Hard coded program (set of pump commands)
void Pump::program(void) {
  this->operate("sf","150");
  this->operate("de","300");
  this->operate("sf","100");
  this->operate("de","300");
  this->operate("sf","50");
  this->operate("de","300");
}

