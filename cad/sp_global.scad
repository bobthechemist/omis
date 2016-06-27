// Auto Titrator Global 

/* *** DESIGN STRATEGY ***

  The syringe pump consists of three parts: gearbox, carriage and idler.
  The gearbox is a compound part containing gears, structure support and
  motor support.  The other two are single pieces.  
  
  Structureal supports are 1/4" stainless steel approximately 130 mm in 
  length.  The lead screw is 1/4" 20 TPI threaded rod.  Support clamps will
  utilize M3x10 bolts (4 bolts 4 nuts needed).  Gearbox will require 3- 
  M3x25 bolts and 2 M3x10 bolts and 7 nuts.

  The lead screw will require a number of 1/4" 20 TPI bolts and jamnuts,
  the number needed for each isn't clear yet.  Possibly 3-4 jamnuts and
  1-2 regular nuts.
  
*/

//Parameters and functions declared here.

//Global parameters

tol = .01; // Used to make preview prettier, should set to 0 for production.

// A set of keys to get the apporpriate values from hardware arrays
// ** DO NOT CHANGE THESE VALUES **
nutDiameter = 0;
nutThickness = 1;
boltDiameter = 2;
jamnutThickness = 3;
x = 0;
y = 1;
z = 2;

/* 
  Considering a standard size for the base plate of each element.  Then,
  if something needs to be trimmed, it can be done within that particular
  module.
*/
baseDim = [3, 60, 70];

/* 
  Hardware arrays are prefixed with hw.  Variable names have M# for
  metric and P# for US (e.g. P4 for #4) or the decimal equivalent of the
  fraction (e.g. 25 for 1/4")
*/
hwM3 = [6.6, 3.0, 3.3]; // M3 metric actual [6.2, 3.0, 2.4]
hw25 = [13.1, 5.8, 6.8, 4.1]; // 1/4"-20 actual [12.8, 6.4, 5.74, 4.17]
hwP4 = [7.8, 3, 3]; // #4 actual [7.34, 2.5, 2.84]

/*
  Attempt to make hardware changes easy - All functions and
  modules should refer to srod, trod and fast so that we can
  change between these dimensions with only one change below.
*/
fast = hwM3;
srod = hw25;
trod = hw25;

// Global design variables
clampDim = [   12, 
            srod[boltDiameter]+1.25*fast[nutDiameter], 
            srod[boltDiameter] + 2];

// Lead screw (or threaded rod) position should be fixed.
trodPosition = [0,0,23];
// Support rod positions are placed relative to the threaded rod.
rodDisplacement = [0, 10, 9];
// Create the positive rod displacment, use vp([1,-1,1],rodPosition) 
//   to get the other
rodPosition = trodPosition + rodDisplacement;

// Syringe array.  To make a single-bore pump, set the separation element 
//  of syringe to 0 (instead of 18).

// ** DO NOT CHANGE THESE VALUES **
diameter = 0;
separation = 1;
position = 2;
thickness = 3;
length = 4;

// Change these values if you wish to customize the syringe pump.
syringe = [12,21,[7,baseDim[y],48],2,10];


// Global programming variables
print_mode = false;  // Set to false for design, true for creating STLs.
debug = false; // For future implementation

//rodClamp(rot=true);
module rodClamp(pos = 0.3,slot=.6,
    fastener = fast, rot=false){
// Rod hole will not be included initially, as doing so
// may result in alignment problems later on.
// rod_clamp will be considered a build up module    
    translate([rot==true?clampDim[x]:0,0,0])
    rotate(rot==true?180:0,[0,0,1])
    translate([0,-0.70*clampDim[y],-0.5*clampDim[z]])
    difference(){
        cube(clampDim);
        union(){
            // bolt
            translate([clampDim[x]/2,pos*clampDim[y],-tol])
            cylinder(d=fastener[boltDiameter],
                h=clampDim[z],$fn=100);
            // nut
            translate([clampDim[x]/2, pos*clampDim[y],
                clampDim[z]-fastener[nutThickness]])
            cylinder(d=fastener[nutDiameter],
                h=fastener[nutThickness]+tol,$fn=6);
            // slot
            translate([-tol,-tol,(clampDim[z]-slot)/2])
            cube([clampDim[x]+2*tol,0.75*clampDim[y],slot]);
            // strain release
            // 0.6*rod_clamp_y is arbitrary, 
            //   and a mix between
            //   relieving strain and having the clamp
            //   come loose from the base.
            //   Cutout thickness (0.8) seems to work OK.
            translate([rot==true?clampDim[x]-0.8+tol:-tol,
                -tol,-tol])
            cube([0.8,0.6*clampDim[y],clampDim[z]+2*tol]);
        }
    }
}

// My first attempt at a linear bearing.  This module
//    creates a perimeter of circles to minimize the 
//    surface area between plastic and rod and possibly
//    allows for holding in grease.  Radius is the 
//    size of the rod and ridge is the radius of the
//    ridge circles.  Ignore tol for the moment.
//  
// This is a build up module but will also need the rod
//    hole cut out.
module bearing(radius=srod[boltDiameter]/2,ridge=1.0,tol=0, debug=false){
    ro = radius+tol;
    ri = ridge;
    r = ro+ri;
    max = floor(360/acos(1-pow(ri,2)/pow(ro,2)));
    if (debug) {
        echo (max);
        echo (str("cut out ", r+ri));
    };
    
    difference(){
    circle(r+ri,$fn=100);
    circle(r,$fn=100);
    }
    for(i=[1:max]){
    translate([r*sin(i/max*360),
        r*cos(i/max*360),0])circle(r=ri,$fn=100);
    }
    
}


// Helper function to return the size of the cutout.  Not
//   a great solution, IMO.  Pass the same paramters as
//   you will to bearing.
function bearing_cutout(radius=srod[boltDiameter]/2,
    ridge=1.0) = radius + 2*ridge;

// Simple function to draw nuts and jamnuts
module nut(hw = trod,jam = false){
    rotate(90,[0,1,0])
    difference(){
        cylinder(d=hw[nutDiameter],
            h=jam?hw[jamnutThickness]:hw[nutThickness],
            $fn=6,center=true);
        cylinder(d=hw[boltDiameter],
            h=1.2*hw[nutThickness],$fn=100,center=true);
    }
}

/*
I often need to multiply vectors element wise.  Here's a simple
 implementation that checks if the vectors are of the same
 length and returns the element-wise vector product if
 applicable and [0] if not.
*/
function vp(v1,v2) = 
    len(v1)==len(v2)?[for (i=[0:len(v1)-1]) v1[i]*v2[i]]:[0];

/*
Likewise, addition of a scalar to a vector, *NO* sanity checks here.
*/
function sa(s,v) = [for (i=[0:len(v)-1]) s+v[i]];


// Some colors
color1 = [97/255,114/255,61/255];
color2 = [162/255,99/255,22/255];
color3 = [148/255,119/255,96/255];
color4 = [185/255,152/255,116/255];
color5 = [99/255,39/255,35/255];


