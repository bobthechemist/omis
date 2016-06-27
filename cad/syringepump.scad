// Autotitrator version 3


include <sp_global.scad>;

use <sp_carriage.scad>;
use <sp_idler.scad>;
use <sp_motor_assembly.scad>;


color(color2)
translate([-10,0,0]+trodPosition)
rotate(90,[0,1,0])
cylinder(d=trod[boltDiameter],h=140,$fn=20);

color(color3)
for(i = [-1,1] ) {
    translate(trodPosition+vp([1,i,1],
        rodDisplacement))
    rotate(90,[0,1,0])
    cylinder(d=srod[boltDiameter],h=140,$fn=20);
}


motorAssembly();
color(color5,0.8)
translate([60,0,0])rotate(180,[0,0,1])carriage();
color([97/255,114/255,61/255],0.9)
translate([130,0,0])rotate(180,[0,0,1])idler();


