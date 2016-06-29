//Test leaking with a simple mixer
//Print with 0.2 mm layer height and 0.3 mm first layer

firstlayerheight = 0.2;
layerheight = 0.1;
base = firstlayerheight + layerheight; 
edge = 1.5; // aiming for a 1.5 mm perimeter
cd = 2; //Channel diameter
cr = cd/2; //Channel radius
dx = 20+2*edge+cd;
dy = 30;
dz = base+cd+2*layerheight;

$design = false;

//Rotations to make channel construction easier
y = [-1,0,0];
x = [0,1,0];

module c(h1=1, dir=x) {rotate(90,dir)cylinder(d=cd,h=h1,$fn=10);}
module s() {sphere(d=cd,$fa=5,$fs=0.2);}

module channels() {
    translate([edge+cr,-0.05,base+cr])c(10.05,y);
    translate([edge+cr,10,base+cr])c(20,x);
    translate([edge+cr+20,10,base+cr])c(10,y);
    translate([edge+cr,20,base+cr])c(20,x);
    translate([edge+cr,20,base+cr])c(10.05,y);
    translate([edge+cr+10,-0.05,base+cr])c(10.05,y);
    //joints
    translate([edge+cr,10,base+cr])s();
    translate([edge+cr+20,10,base+cr])s();
    translate([edge+cr+20,20,base+cr])s();
    translate([edge+cr,20,base+cr])s();   
}

module case() {
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
