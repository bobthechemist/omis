#include "Arduino.h"
#include "Pump.h"

int Pump::operate(String op, String arg){

  if      ( op == "ss" ) {
    float tmp = constrain(arg.toFloat(),this->minRPM, this->maxRPM);
    Serial.print("Setting RPMs to: ");
    Serial.println(tmp);
    this->setSpeed(tmp);
  }
  else if ( op == "mv" ) {
    Serial.print("Moving this many steps: ");
    Serial.println(arg.toInt());
    this->step(arg.toInt());
  }
  else if ( op == "tu" ) {
    Serial.print("Performing this many turns: ");
    Serial.println(arg.toFloat());
    this->turn(arg.toFloat());
  }
  else if ( op == "sf" ) {
    float tmp = constrain(
      this->FRtoRPM(arg.toFloat()),
      this->minRPM,
      this->maxRPM);
    Serial.print("Setting RPMs to: ");
    Serial.println(tmp);
    this->setSpeed(tmp);
  }
  else if ( op == "de" ) {
    Serial.print("Delivering this many uL: ");
    Serial.println(arg.toFloat());
    this->step(VOLtoSTEPS(arg.toFloat()) );
  }
  else if (op == "go") {
    Serial.println("Starting program");
    this->program();
    Serial.println("Finished program");
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

