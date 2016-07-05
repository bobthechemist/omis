//Test leaking with a simple mixer
//Print with 0.2 mm layer height and 0.3 mm first layer

$iteration = 1;

firstlayerheight = 0.2;
layerheight = 0.1;
base = firstlayerheight + layerheight; 
edge = 1.5; // aiming for a 1.5 mm perimeter
cd = 2; //Channel diameter
cr = cd/2; //Channel radius
dx = 40;
dy = 24;
dz = base+cd+2*layerheight;

$design = true;

//Rotations to make channel construction easier
y = [-1,0,0];
x = [0,1,0];

module c(h1=1, dir=x, d = cd) {rotate(90,dir)cylinder(d=d,h=h1,$fn=20);}
module s(d = cd) {sphere(d=d,$fa=5,$fs=0.2);}

module channels() {
    translate([-10,5,base+cr])c(10,x,cd/2);
    translate([-10,-5,base+cr])c(10,x,cd/2);
    translate([0,-5,base+cr])c(10,y,cd/2);
    translate([0,0,base+cr])c(5,x,cd);
    translate([5,0,base+cr])c(10,y,cd);
    translate([5,10,base+cr])c(5,x,cd);
    translate([10,-10,base+cr])c(20,y,cd);
    translate([10,-10,base+cr])c(5,x,cd);
    translate([15,-10,base+cr])c(10,y,cd);
    translate([15,0,base+cr])c(5,x,cd);
    translate([20,-5,base+cr])c(10,y,cd/2);
    translate([20,5,base+cr])c(10,x,cd/2);
    translate([20,-5,base+cr])c(10,x,cd/2);
    //joints
    translate([0,0,base+cr])s(cd);
    translate([0,5,base+cr])s(cd/2);
    translate([0,-5,base+cr])s(cd/2);
    translate([5,0,base+cr])s(cd);
    translate([5,10,base+cr])s(cd);
    translate([10,10,base+cr])s(cd);
    translate([10,-10,base+cr])s(cd);
    translate([15,-10,base+cr])s(cd);
    translate([15,0,base+cr])s(cd);
    translate([20,0,base+cr])s(cd);
    translate([20,5,base+cr])s(cd/2);
    translate([20,-5,base+cr])s(cd/2);
    //entry ports
    for(i=[5,-5])
        translate([-10,i,base+cr])
        rotate(90,x){
            cylinder(d=cd,h=3,$fn=20);
            translate([0,0,3])
            cylinder(d=cd,d2=cd/2,h=2,$fn=20);
        }

    //exit ports
    for(i=[5,-5])
    translate([30,i,base+cr])
    rotate(-90,x){
        cylinder(d=cd,h=3,$fn=20);
        translate([0,0,3])
        cylinder(d=cd,d2=cd/2,h=2,$fn=20);
    }    

    
}

module case() {
    translate([-10,-dy/2,0])
    cube([dx,dy,dz]);
}



if($design) {
    channels();
    color("blue",0.4)case();
}
else {
    
    difference(){
        case();
        channels();
    }
}
