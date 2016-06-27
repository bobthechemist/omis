/* definitions
v is vertical width (up/down)
h is horizontal width (left/right)
l is length of channel
*/

// When designing, set to true so pieces render in 
//  a cleaner fashion.  **WARNING** objects created
//  with $design = true will not print properly.

$design = true;
$tol = 0.01;


// Channel dimensions, vertical and horizontal widths
cv = 1; ch = 1.6;
// Port dimensions, radius, thickness and height
pr = 0.96; pt = 0.8; ph = 3;
// Device dimensions.  Arbitrary x and y, z determined
//   so there is one base layer and 2 top layers with
//   a 0.2 um layer height and a 0.3 um first layer.
baseDim = [28,19,0.7+cv];

// Device parameters (channels and ports)

// [x,y], horiz width, vert. width, length, direction
channels = [
    [ [0,0], ch, cv, 20, true ],
    [ [0,10], ch, cv, 20, true ],
    [ [20,-ch/2], ch, cv, 10+ch, false ],
    [ [10,0], ch, cv, 6, false ]
];

// [x, y]
ports = [
    [ 0.5, 0 ], 
    [ 10., 5.5 ],
    [ 0.5, 10 ]
];

// Creates a rectangular channel
module ch(h=1,v=0.6,l=10,x=false) {
    
    rotate(x?0:180,[0,0,1])
    rotate(x?90:0,[0,0,1])
    rotate(90,[1,0,0])
    translate([-h/2,0,0])
    linear_extrude(l)square([h,v]);
}



// Takes an array of parameters to create all channels
module makeChannels() {
    for (c=channels) {
        translate([c[0][0],c[0][1],0.3])
        ch(h=c[1],v=c[2],l=c[3],x=c[4]);
    }
}


// Ports are constructed differently for 
module makePortsAdd() {
    for (p=ports) {
        translate([p[0],p[1],cv+.3])
        cylinder(r=pr+pt,h=ph,$fn=100);
    }
}
module makePortsSubtract() {
    for (p=ports) {
        translate([p[0],p[1],0.3+cv-($design?$tol:0)])
        cylinder(r=pr,h=($design?2*$tol:0)+ph,$fn=100);
    }
}
module makePorts() {
    difference() { 
        makePortsAdd(); 
        makePortsSubtract();
    }
}

module makeCase() {
    translate([-4,-4.5,0])
    cube(baseDim);
}

if($design) {
    makeChannels();
    makePorts();
    color("blue",0.4)makeCase();
}
else {
    difference() {
        union(){
            makeCase();
            makePortsAdd();
        }
        union() {
            makeChannels();
            makePortsSubtract();
        }
    }
}

