include <sp_global.scad>;
use <MCAD/2dshapes.scad>;


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
                rotate(90,[0,1,0])
                rotate(-90,[0,0,1])
                linear_extrude(syringe[length])
                donutSlice(
                    syringe[diameter]/2, 
                    syringe[diameter]/2 +
                    syringe[thickness],0,180,$fn=100);
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
            // Trim top, save plastic
            translate(sa(-tol,vp([-1/2,-1/2,0.9],baseDim)))
            cube(sa(2*tol,vp([1.,1.,0.1],baseDim)));
        }
    }
}



 
  

if (build_mode) idler();
