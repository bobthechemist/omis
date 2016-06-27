include <sp_global.scad>;
use <MCAD/2dshapes.scad>;

print_mode = true;

/* 
  Following 3 modules make a brace for the syringe(s).  The whole design
  is cut into two pieces so that the top piece can be printed separately
*/

module wholeSyringeHolder(){
    linear_extrude(syringe[length]) {
        donutSlice(
            syringe[diameter]/2,
            syringe[diameter]/2 +
            syringe[thickness],0,360,$fn=100
        );
        for(i=[0,1]){
            mirror([i,0,0])
            translate([syringe[diameter]/2,0])
            square([2*fast[boltDiameter]+1,4]);
        }
        
    }
}


module topSyringeHolder() {
    difference(){
        wholeSyringeHolder();
        translate([-50,-98,-1])
        cube([100,100,100]);
    }
}
module bottomSyringeHolder() {
    difference() {
        wholeSyringeHolder();
        translate([-50,2,-1])
        cube([100,100,100]);
    }
}


module idler(){
    difference(){
        // Buildup
        union(){
            // Base
            translate([0,0,baseDim[z]/2])
            cube(baseDim,center=true);  
            for(i = [ [-1, false], [1, true] ] ){
                translate([baseDim[x]/2, i[0]*rodPosition[y],
                rodPosition[z]])
                rodClamp(rot=i[1]);
            }
            //Syringe support  
            for(i=[-1,1]){
                translate([
                    baseDim[x]/2, 
                    i*syringe[separation]/2,
                    syringe[position][z]])
                rotate(90,[1,0,0])
                rotate(90,[0,1,0]){
                    bottomSyringeHolder();
                    translate([0,2,0])
                    topSyringeHolder();
                    
                }
            }
        }
        // Remove
        union(){
            // Threaded rod 
            //   The 0*baseDim[x] can be adjusted if
            //   threaded rod needs more support.
            //   -0.4,0.4 recommended limits.
            translate([0*baseDim[x],
                trodPosition[y],trodPosition[z]])
            rotate(90,[0,1,0])
            cylinder(d=trod[boltDiameter], 
                h=baseDim[x],$fn=100);
            // Structural rod 
            for (loop = [-1,1]){
                translate([-tol+clampDim[x]/2,
                    loop*rodPosition[y],
                    rodPosition[z]])
                rotate(90,[0,1,0])
                cylinder(d=srod[boltDiameter],
                    h=baseDim[x]+clampDim[x]+4*tol,
                    $fn=100,center=true);
            }
            // Syringe hole and support
            for(i=[-1,1]){
                translate([-tol,i*syringe[separation]/2,
                    syringe[position][z]])
                rotate(90,[0,1,0])
                cylinder(d=syringe[diameter], 
                    h=baseDim[x]+4*tol,
                    $fn=100,center=true);
            }
            // NOT YET FULLY PARAMETERIZED
            // Syringe support bolt holes
            translate([(baseDim[x]+syringe[length])/2,
                0,syringe[position][z]])
            cylinder(d=fast[boltDiameter]+.2,h=20,
            center=true,$fn=100);
            // Trim top, save plastic
            translate(sa(-tol,
                vp([-1/2,-1/2,0.715],baseDim)))
            cube(sa(2*tol,vp([1.,1.,0.285],baseDim)));
        }
    }
}



 
  

if (print_mode) {
    // A bit messy due to syringe brace
    difference(){
        translate([0,0,baseDim[x]/2])
        rotate(90,[0,-1,0])
        idler();
        translate([-100,-100,0])
        cube([49,200,50]);
    }
    translate([65,0,-3])
    rotate(0,[0,1,0])
    difference(){
        translate([0,0,baseDim[x]/2])
        rotate(90,[0,-1,0])
        idler();
        translate([-50.1,-100,-1])
        cube([55,200,50]);
    }
}
else {
    idler();
}

