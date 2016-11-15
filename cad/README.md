##CAD files

###Syringe pump files
The syringe pump consists of three design files (one for each of the components of the syringe pump), a global variables and functions file and a summary file.  The CAD files have been designed such that the typical changes an end user may make (support rod and lead screw dimensions, fastener types, syringe properties) can all be customized within a single file.

- **sp_global** is the location for all global variables and functions used by the other design files.
- **syringepump** allows the end user to view the entire project.  It is not meant for actual use but to ensure that features and spacing is consistent throughout the design.
- **sp\_motor\_assembly** contains the gear train and components used to hold the stepper motor in place.
- **sp_carriage** is the moving piece that pushes the syringes
- **sp_idler** is the end cap that supports the structural and threaded rods, and also provides support for the syringes.

There are currently two example millifluidic devices, one with side ports and one with top-face ports.  The side-port version uses cylindrical channels and the top-face port version uses rectangular channels.  These devices are designed with exploration in mind, while we identify best practices for 3D printed millifluidic device fabrication.

### Change log

**in development**
----
- Carved pieces from the syringe support on the idler in order to make gripping the upper part a bit easier

- Starting to work through pieces and provide an option to minimize filament use.

- 161114: After a semester of use, it appears that the rod clamp attachment is a weak point and causes device failure (with both PLA and PETG).  Changed clamp to have a larger base attached to the substrate plate, which required that the support rods be moved farther apart from one another.