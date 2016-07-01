#include "Arduino.h"
#include "CommandParser.h"

CommandParser::CommandParser(){
  this->command = "";
  this->command.reserve(100);
  this->commandComplete = false;
}

// For debugging purposes
void CommandParser::print(void) {
  Serial.print("command: ");
  Serial.println(this->command);
  Serial.print("operation: ");
  Serial.println(this->operation);
  Serial.print("argument: ");
  Serial.println(this->argument);
}

// Lifted from the serialEvent example
void CommandParser::read(void){
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    this->command += inChar;
    // if the incoming character is a newline, set a flag
    // so the main loop can do something about it:
    if (inChar == '\n') {
      this->command.trim();  // Remove the newline we just added
      this->commandComplete = true;
    }
  }
}

// Clears the command and gets ready to receive a new one
void CommandParser::refresh(void) {
  this->command = "";
  this->commandComplete = false;
}

// Split the command into its operation and arguments
void CommandParser::parse(void) {
  // operations and arguments are separated by a space.
  int seperator;
  seperator = this->command.indexOf(' ');
  this->operation = this->command.substring(0,seperator);
  this->argument = this->command.substring(seperator+1);

}

// Does some sanity checking
boolean CommandParser::validate(void) {
  // Check to see if command is complete
  if (!this->commandComplete) return false;
  
  // If there is no space, then the command is not valid.
  if (this->command.indexOf(' ')<=0) {
    Serial.println("Command not valid");
    this->command = "";
    this->commandComplete = false;

    return false;
  }
  return true;
}

