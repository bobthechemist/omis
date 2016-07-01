# Arduino sketch and schematic

## Electronics

The breadboard layout, shown below, is identical to the one described in the [Adafruit tutorial on stepper motors](https://learn.adafruit.com/adafruit-arduino-lesson-16-stepper-motors/parts?view=all).  That tutorial is a prerequisite to building the electronics/software side of OMIS.  

![breadboard layout](https://cdn-learn.adafruit.com/assets/assets/000/002/495/medium640/learn_arduino_fritzing.jpg?1396783754)

## Sketch

The sketch is broken up into several components, in hopes to make it easier to modify the code.  Note that OMIS uses a modified version of the [Arduino stepper library](https://www.arduino.cc/en/Reference/Stepper).  The primary reason for the modified version is to allow for non-integer RPM values to be passed to the motor.  It also has some helpful(?) functions related to the pump such as determining the volume flow rate for a given motor speed.   Additionally, it contains the operations to be performed when receiving commands via the Serial line.

The other component to the sketch is the Command Parser, which is a very primitive class that deals with serial communication and performs some basic sanity checking.

To install, simply move the software directory and its contents into your Arduino directory, and rename the directory syringepump.




