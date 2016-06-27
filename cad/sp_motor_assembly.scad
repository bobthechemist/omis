// Autotitrator motor assembly
/* 
This version incorporates a compound gear train to improve the
torque applied to the lead screw.  Some adjustments made to the
orientation of the suppor rod clamps to allow for printing on one 
side only.

Unlike the first version, this one incorporates gears into the
assembly as opposed to having a separate file.
*/

include <sp_global.scad>;
use <MCAD/involute_gears.scad>;

print_mode = false;

// Gear pitch radii
// 0 is motor, 1 is larger cmpd, 2 is smaller cmpd and 3 is driven
pitchRadius = [5.8333, 17.5, 4, 20];
// Where to put the three support screws, one is aligned with the 
//   compound gear.
gearboxSupport = [ [0,0.4*baseDim[y],0.8*baseDim[z]],
                [0,-0.4*baseDim[y],0.8*baseDim[z]],
                [0,0,
                trodPosition[z]+pitchRadius[2]+pitchRadius[3]]];

// Build up modules
module base(){
    difference(){
        union(){
            translate([0,0,1/2*baseDim[z]])
            cube(baseDim,center=true);
            structuralRodSupports();
        }
        union() {
            threadedRodCutout();
            structuralRodCutout();
            gearboxSupports();
        }
    }
}

module gearboxSupports(){
    // gearbox support holes
    for (i = gearboxSupport) {
        translate(i)
        rotate(90,[0,1,0]){
            cylinder(d=fast[nutDiameter],
                h=1.2*baseDim[y],center=false,$fn=6);
            cylinder(d=fast[boltDiameter],
                h=1.2*baseDim[y],center=true,$fn=25);
        }
    }   
}

module structuralRodSupports() {
    for(i = [ [-1, false], [1, true] ] ){
        translate([baseDim[x]/2, i[0]*rodPosition[y], rodPosition[z]])
        rodClamp(rot=i[1]);
    }    
}

module gearBox(){
    shaft_z = trodPosition[z]+pitchRadius[0] + pitchRadius[1] +
        pitchRadius[2] + pitchRadius[3];
    cmpd_z = trodPosition[z] + pitchRadius[2] + pitchRadius[3];
    difference() {
        union() {
            translate([0,0,1/2*baseDim[z]])
            cube(baseDim,center=true);
            translate([0,0,cmpd_z])
            *rotate(90,[0,1,0]){
                cylinder(d=2.7,h=15,$fn=10);
                cylinder(d=5,h=5);
            }
        }
        union() {
            // motor cutout
            translate([-baseDim[x]/1.9,-baseDim[y]/1.9,baseDim[z]])
            cube([baseDim[x]*1.1,baseDim[y]*1.1,200]);
            translate([0,0,shaft_z])
            rotate(90,[0,1,0])
            cylinder(d=17,h=1.1*baseDim[x],center=true,$fn=25);
            // motor support cutout
            for (i = [-1,1] ) {
                translate([0,i*35/2,shaft_z-8])
                rotate(90,[0,1,0])
                cylinder(d=3.5,h=2.2*baseDim[x],center=true,$fn=25);
                translate([-baseDim[x]/1.9,i*35/2-3.5/2,shaft_z-8])
                cube([baseDim[x]*1.1,3.5,25]);
            }
            // gearbox screw holes
            translate([0,0,cmpd_z])
            rotate(90,[0,1,0])
            cylinder(d=fast[boltDiameter],
                h=1.2*baseDim[y],center=true,$fn=25);
            // gearbox support holes
            for (i = gearboxSupport) {
                translate(i)
                rotate(90,[0,1,0])
                cylinder(d=fast[boltDiameter],
                    h=1.2*baseDim[y],center=true,$fn=25);
            }
            // trim unused part of plate
            translate([0,0,0]);
            cube(1.01*baseDim,center=true);
                
        }
    }
}

module gearDriven(){
    gear_z = 3;
    difference(){
        gear(circular_pitch = 240,
            number_of_teeth = 30, 
            rim_thickness = gear_z,
            hub_thickness = 0,
            gear_thickness = gear_z,
            bore_diameter = 0,
            circles = 8,
            rim_width = 1.5,
            hub_diameter = 15
            );
        cylinder(d=trod[nutDiameter],h=2.1*gear_z,center=true,$fn=6);
    }
}

module gearCompound(){
    gear_z1 = 3;
    gear_z2 = 7;
    difference(){
        union(){
            gear (circular_pitch = 350,
                number_of_teeth = 18,
                rim_thickness = gear_z1,
                hub_thickness = 0,
                gear_thickness = gear_z1,
                bore_diameter = 0
            );
            translate([0,0,gear_z1])
            gear (circular_pitch = 240,
                number_of_teeth = 6,
                rim_thickness = gear_z2,
                hub_thickness = 0,
                gear_thickness = gear_z2,
                bore_diameter = 0,
                rim_width = 0,
                hub_diameter=0
            );
        }
        cylinder(d=fast[boltDiameter]+0.05,
            h=2.1*(gear_z1+gear_z2),center=true,$fn=10);
    }
}

module gearMotor() {
    gear_z = 9;
    difference() {
        translate([0,0,15])
        rotate(180,[0,1,0])
        gear (circular_pitch = 350,
            number_of_teeth=6,
            rim_thickness = gear_z,
            hub_thickness = 12,
            gear_thickness = gear_z,
            bore_diameter = 0,
            hub_diameter=16
        );
        union(){
            translate([0,0,4])
            cylinder(d=5.2,h=3,center=true,$fn=10);
            translate([0,0,0])linear_extrude(16){
                intersection(){
                    circle(d=5.2,$fn=25);
                    square([3.3,5.2],center=true);
                }
            }
        }
    }
}
    
            
    
// Removal modules
module threadedRodCutout(){
    translate([0,trodPosition[y],trodPosition[z]])
    rotate(90,[0,1,0])
    cylinder(d=trod[boltDiameter],
        h=baseDim[x]+2*tol,$fn=25,center=true);
}
module structuralRodCutout(){
    for (i = [-1,1] ) {
        translate([-baseDim[x]/2-tol,
            i*rodPosition[y],rodPosition[z]])
        rotate(90,[0,1,0])
        cylinder(d=srod[boltDiameter],
            h=baseDim[x]+clampDim[x]+2*tol,$fn=25);
    }
}

module motorAssembly(){
    color(color1,1)
    translate([-17.5,0,0])
    gearBox();

    color(color3,0.9)
    translate([-22,0,trodPosition[z]+
        pitchRadius[0]+pitchRadius[1]+pitchRadius[2]+pitchRadius[3]])
    rotate(90,[0,1,0])
    gearMotor();

    color(color4,0.9)
    translate([-12.5,0,trodPosition[z]+pitchRadius[2]+pitchRadius[3]])
    rotate(90,[0,1,0])
    rotate(360/12,[0,0,1])
    gearCompound();
    
    color(color3,0.9)
    translate([-9,trodPosition[y],trodPosition[z]])
    rotate(90,[0,1,0])
    gearDriven();
    
    *translate([-7,0,trodPosition[z]])nut(jam=true);
    *translate([-12.7,0,trodPosition[z]])nut(jam=true);

    color(color1,0.6)
    base();
    

}



whichplate = 0;

if (!print_mode) {
    motorAssembly();
}
else {
    
    // Use an asterick before items you don't want on the build plate.
    translate([-25,0,baseDim[x]/2])
    rotate(90,[0,1,0])gearBox();
    translate([0,0,baseDim[x]/2])
    rotate(90,[0,-1,0])base();
    translate([-60,45,-4.5+baseDim[x]/2])gearMotor();
    translate([20,55,0])gearDriven();
    translate([-25,55,0])gearCompound();
}



