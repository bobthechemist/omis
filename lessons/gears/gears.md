

#An introduction to gears with the OMIS syringe pump
##Notes (to be deleted for production)
- what are gears?
	- wheels with teeth
- what do they do?
	- change speed, direction or torque
- [Watch an introductory video on gears](https://www.youtube.com/watch?v=odpsm3ybPsA)
	- Questions from the video
	- How to use 3D printed gears to explore further
		- what is the "appropriately-spaced" board?
- Terminology
	- gear, mechanical advantage, gear ratio, spur gear, compound gear, gear pitch, teeth, torque
- Equations needed
	- gear ratios, pitch radius
- some useful definitions with pictures [here](http://www.dsnell.co.uk/PS/wProSpur.html)

I would like students to define some gear terminology, understand the concept of mechanical advantage, apply gear ratios to solve gear-based problems, analyze a gear train for the overall mechanical advantage, and create a gear train with specific constraints.

## an introduction to gears

One of the first design challenges faced with the OMIS syringe pump is the mechanical limitations of the stepper motor.  It is cheap, small and can be powered from the Arduino microcontroller, all of which are favorable properties.  However, the amount of [torque](https://www.physics.uoguelph.ca/tutorials/torque/Q.torque.intro.html) (the force applied to twist or rotate an object) is too low to provide the force necessary to dispense fluid out of a syringe.  

We can use *gears* to overcome this challenge.  A simple description of a gear is a [wheel with teeth](https://www.google.com/search?q=images+of+gears&tbm=isch).  Gears provide something called mechanical advantage, which is a unitless number that describes how a machine helps with a task.  We'll discuss mechanical advantage in more detail shortly.

Before going further, it would be a good idea to [Watch an introductory video on gears](https://www.youtube.com/watch?v=odpsm3ybPsA).  After watching the video, you should be able to answer the following questions:

1. What are the three things that a gear can do? 
2. What property of a gear affects its ability to interact with another gear?
3. If you are cycling up a hill, do you want the gear ratio of your bike to be close to 1 or much larger than 1? 

Here is a view of the OMIS syringe pump gear train:

![](omisgears.png)

The gear train consists of three gears: a *motor* gear that is attached to the stepper motor.  This is the gear that will drive the rest of the gear train.  The second gear is a *compound gear*. (We could also refer to this gear as an *idler*, but since that term is used for a different part of the syringe pump, I chose not to use it.) Note how it is actually a set of gears connected to one another.  Because they are connected, the two parts will always move at the same speed; however since the two parts have different numbers of teeth, they will interact with other gears differently.  When referring to the compound gear, I will specify if I am talking about the larger or smaller part.  Finally, there is the *driven* gear, which is the one that is connected to the threaded rod (or lead screw) that ultimately pushes the fluid out of the syringes.


To start, let's look at the first two gears in the OMIS syringe pump, the Motor and Compound gears.  How many teeth does the *motor gear* have?  How many are on the larger portion of the compound gear?  The gear ratio *n* can be calculated using

\\begin{equation}
	n = \frac {teeth\_{load}}{teeth\_{motor}}
	\\label{eq:gearratio}
\\end{equation}  

I use the general term *load* to refer to the gear that is *not* connected to the motor, which in this example is the compound gear.  Using equation \\eqref{eq:gearratio}, calculate the gear ratio for the motor and compound gear. 

The gear ratio is also the [*mechanical advantage*](https://en.wikipedia.org/wiki/Mechanical_advantage#Gear_trains) and this value can be used to determine the relative speed and torque of gears in a gear train.  In fact, the relative speeds of the two gears is equal to the inverse of the mechanical advantage:

\\begin{equation}
	\frac 1{MA}=\frac {RPM\_{load}}{RPM\_{motor}}
	\\label{eq:mainv}
\\end{equation} 

A simpler form of equation \\eqref{eq:mainv} can be obtained by  cross multiplying and rearranging:

\\begin{equation}
	MA = \frac {RPM\_{motor}}{RPM\_{load}}
	\\label{eq:ma}
\\end{equation}

In the OMIS syringe pump, you can select motor speeds from 1 RPM (rotation per minute) to 40 RPM.  Using the above equations, determine the range of rotational speeds expected for the compound gear.  How will the speed of the load gear change if the mechanical advantage increases and the speed of the motor gear stays the same?  If you want to decrease the speed of the load gear but keep the motor gear speed the same, would you add or remove teeth to the load gear?

### working with gears
We use gears to make life easier.  In physics, work is the force applied to an object multiplied by the distance traveled by the object as a result of that work.  If time is added to the picture (how much work is done during a given time frame) we have power.  

When dealing with rotational motion, we use the term torque instead of force, but the idea is the same; work is the product of the torque applied to an object and the amount the object turns as a result of that torque.  Power, then is the product of the torque and angular velocity (in other words, RPMs) of the object.  

In an ideal world, the power applied to a gear train is equal to the power exerted by the gear train.  (Pin = Pout).  If we substitute the power equation, we get (T1 w1 = T2 w2).  Notice that if we move all the w's to one side and all the T's to the other, we get T1/T2 = w2/w1.  We know from the previous section that w2/w1 is equal to 1/MA, so a bit more algebra and we get a relationship between the input and output torque T1*MA = T2.  

If the motor can apply a torque of 30 mM m (a typical value for this motor based on the datasheet and a unit conversion website), how much torque is exerted by the compound gear?

There is a lot more to gear math (and real gears with friction) but the general concepts presented here should suffice for now.  There are several important take-home messages at this point:

- Gears provide mechanical advantage that can change the speed, direction and torque applied to an object.
- Torque or speed (but not both) can be increased with a gear train.
- Mechanical advantage, or gear ratio, is the ratio of teeth in two meshing gears.
- A mechanical advantage greater than 1 increases torque and a mechanical advantage less than 1 increases speed. 


###Completing the gear train

The OMIS syringe pump uses a gear train to create a large mechanical advantage in a small space.  We can use the same concepts above to determine the relationship between the motor gear and the driven gear, even though the two gears never touch one another. (They are related to one another through the compound gear.)

As with the first part, some information is needed about the gear train:

- Number of teeth on the smaller portion of the compound gear:
- Number of teeth on the driven gear:
- Mechanical advantage between the compound gear and the driven gear:

Let's assume that the speed of the motor is 15 RPM, calculate the speed of the compound gear using the equation above.  Now, since we know the mechanical advantage between the compound and driven gears, and we know the speed of the compound gear, the speed of the driven gear can be obtained using the same equation.

When these two equations are rearranged, it becomes apparent that the *product of the mechanical advantages of the gears in a gear train is the overall mechanical advantage of the gear train*.

###Sizes of gears

It was mentioned earlier that in order for gears to work together (in other words *mesh*) they must have similarly sized and shaped teeth.  This property of a gear is referred to as *pitch*.  If the teeth need to be the same size and shape, then to put more teeth around a wheel (to make a gear) then the size of the wheel (its radius) must increase as well.  The circumference of a gear is (essentially)<sup>1</sup> the same as the circumference of a circle with the same diameter.  If N teeth are spaced evenly around the circumference, then one can calculate the pitch using d * Pi/N=p.  It is this value, *p* that must be the same for meshing gears.  Rearranging this equation and converting to degrees, the equation becomes d = N * p / 180 we see that for meshing gears there are two constants (p and 180) therefore if the number of teeth increases (N) then the diameter of the gear must increase (d).  

For the motor and larger portion of the compound gear, the circular pitch is 350 mm.  Knowing the number of teeth from an earlier part of this activity, calculate the radii of the two gears.

In the design of the OMIS syringe pump, these radii were important to calculate because they determine the distance between the shafts of the two gears.  Place the gears too far apart, and they won't interact.  Often in designing scientific instruments, size is an important consideration.  I knew how much space I wanted to allocate to the gear train, which defined the radii of the gears, which in turn dictated the circular pitch, which influences the number of teeth and ultimately the mechanical advantage of the gear train.  That's a lot to think about!

####why use a compound gear?
As mentioned earlier, a gear train designed to increase torque requires a mechanical advantage greater than 1, which is accomplished by having small gears drive large gears.  If a compound gear was not used in the OMIS syringe pump,  then the driven gear would have to be much larger.  Let's figure out how much larger.

The OMIS syringe pump gear train provides a mechanical advantage of 15.  If we wanted to build a 3-gear gear train that did not use a compound gear, calculate the number of teeth required for the driven gear in order to obtain the same mechanical advantage.  Using a circular pitch of 350 mm, what is the radius of this new gear?  How does it compare to the radius of the driven gear in the OMIS syringe pump?

These calculations should make clear the benefits of a compound gear.  Prior to the advent of readily accessible 3D printing, obtaining compound gears of customized sizes and shapes was very difficult.

##Help design OMIS syringe pump version 2
We've worked through some of my rationale for designing the gear train in the OMIS syringe pump.  There are some other less-rational design choices based on historical reasons (for example some of the dimensions are based on very early designs).  Now that we know more about gears, mechanical advantage, and the desired operating parameters of the end product, it might be beneficial to redesign the gear train from the ground up.  Are you up for the challenge?

Here are some design parameters:

- Newer versions always seem smaller than the previous versions.  Therefore, the new gear train can't be larger than the current dimensions; it must fit into a space that is 60 mm wide and 70 mm high (or less).
- the smallest practical number of teeth on a 3D printed gear is 6.
- the driven gear speeds should cover the same range as they do now for motor speeds from 1 to 40 RPM.  **However**, after some experimentation, it turns out that the motor is unreliable at speeds above 30 RPM.  Therefore, the new design will need to provide the same driven gear speeds with a lower motor speed. 

#Conclusion
In this activity, you have learned some of the design principles used to create the gear train in the OMIS syringe pump.  You know have some familiarity with important gear concepts such as the mechanical advantage, speed and torque relationships, and pitch radius.  You should have an appreciation for the use of compound gears and can design a gear train that meets a given set of design parameters.  Now you can think about how to incorporate gears into your own designs.


<sup>1</sup>Do we measure the circumference of the *base* of the teeth or the tip of the teeth?  Actually, we split the difference.




