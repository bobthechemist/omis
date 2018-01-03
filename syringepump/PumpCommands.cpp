#include "Arduino.h"
#include "Pump.h"

const char pumpBusyErrorString[] = "ERROR: Pump is busy.";

// TODO: Consider switch case
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
    else {Serial.println(pumpBusyErrorString);}
  }
  else if ( op == "tu" ) {
    if(this->addSteps( long(arg.toFloat() * this->number_of_steps ))) {
      Serial.println("Performing " + arg + " turn(s).");
    }
    else {Serial.println(pumpBusyErrorString);}
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
    else {Serial.println(pumpBusyErrorString);}
  }
  else if (op == "un") {
    Serial.println("Unlocking motor");
    this->unlock();
  }
  else if (op == "en") {
    if(arg.toInt()==1) {
      Serial.println("Enabling pump.");
    }
    else {
      Serial.println("Disabling pump");
    }
    this->enable(arg.toInt());
  }
  else {
    Serial.println("Invalid command");
    return 0;
  }
  return 1;
}



