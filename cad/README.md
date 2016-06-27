##CAD files
*Note, this file pertains to a prelease version (<1.0) of OMIS and is subject to change*
###Syringe pump files
The syringe pump consists of three design files (one for each of the components of the syringe pump), a global variables and functions file and a summary file.  The CAD files have been designed such that the typical changes an end user may make (support rod and lead screw dimensions, fastener types, syringe properties) can all be customized within a single file.

- **sp_global** is the location for all global variables and functions used by the other design files.
- **syringepump** allows the end user to view the entire project.  It is not meant for actual use but to ensure that features and spacing is consistent throughout the design.
- **sp_motor_assembly** contains the gear train and components used to hold the stepper motor in place.
- **sp_carriage** is the moving piece that pushes the syringes
- **sp_idler** is the end cap that supports the structural and threaded rods, and also provides support for the syringes.
