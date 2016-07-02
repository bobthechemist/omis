#Change Log

##Development branch
- added unlock command to de-energize coils.  Unlocking allows for motor to turn but drops current use from ~ 50 mA to 0. At present, I do not know the performance implications of unlocking the motor.
- added a feature to enable/disable the L293D.  This requires a change to the schematic (not sure how this affects versioning) tying pins 1 and 9 to a single digital pin on Arduino.  Change allows user to drop current draw to about 13 mA.

## Version 0.1
First public version.  Rudimentary command structure, hard-coded scripting option, serial communication, customized stepper motor library