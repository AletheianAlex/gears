//$ fn = 96;

// ACK NOTE:, I didn't touch the word "rad" since it could refer to radians or wheel
/* Library for involute gears, screws and racks
 
 Contains the modules
 - rack (module, length, height, width, pressure_angle = 20, angle = 0)
 - track_gear (module, tooth_number, width, bore, pressure_angle = 20, angle = 0, optimized = true)
 - arrow_gear (modul, tooth_number, width, bore, pressure_angle = 20, angle = 0, optimized = true)
 - rack_and_rad (module, length_bar, tooth_tooth_rad, height_bar, bore_rad, width, pressure_angle = 20, angle = 0, together_built = true, optimized = true)
 - ring_gear (module, tooth_number, width, border_width, pressure_angle = 20, angle = 0)
 - arrow_ring_gear (modul, tooth_number, width, borderwidth, pressure_angle = 20, angle = 0)
 - planetary_gear (module, tooth_number_sun, tooth_planet_planet, number_planets, width, border_width, bore, pressure_angle = 20, angle = 0, together_built = true, optimized = true)
 - bevel_gear (modul, tooth_number, part cone angle, tooth width, bore, pressure_angle = 20, angle = 0)
 - bevel_arrow_gear (modul, tooth_number, part cone angle, tooth width, bore, pressure_angle = 20, angle = 0)
 - bevel_gear_pair (modul, tooth_tooth_rad, tooth_type_pinion, axis_angle = 90, tooth_width, bore, pressure_angle = 20, angle = 0, together_built = true)
 - bevel_arrow_gear_pair (modul, tooth_tooth_rad, sprocket_pinion, axis_angle = 90, tooth_width, bore, pressure_angle = 20, angle = 0, together_built = true)
 - worm (module, number of steps, length, bore, pressure_angle = 20, angle = 10, together_built = true)
 - worm_gear (modul, tooth_number, number of steps, width, length, bore_screw, bore_rad, pressure_angle = 20, angle = 0, optimized = true, together_built = true)
 
 Examples of each module are commented out at the end of this file
 
 Author: Dr Jörg Janssen
 As of: 1 June 2018
 Version: 2.2
 License: Creative Commons Attribution, Non Commercial, Share Alike
 
 Permitted modules DIN 780:
 0.05 0.06 0.08 0.10 0.12 0.16
 0.20 0.25 0.3  0.4  0.5  0.6
 0.7  0.8  0.9  1    1.25 1.5
 2    2.5  3    4    5    6
 8    10   12   16   20   25
 32   40   50   60
 
 */


// general variables
pi = 3.14159;
rad = 57.29578;
play = 0.05; // play between teeth

/* Convert Radian to degrees */
function grad(pressure_angle) = pressure_angle*rad;

/* Converts degrees to Radian */
function radian(pressure_angle) = pressure_angle/rad;

/* Converts 2D polar coordinates to Cartesian
 Format: radius, phi; phi = angle to x-axis on xy plane */
function pole_to_cart(polvect) = [
                                 polvect[0]*cos(polvect[1]),
                                 polvect[0]*sin(polvect[1])
                                 ];

/* Circle involute function:
 Returns the polar coordinates of a circle involute
 r = radius of the base circle
 rho = roll angle in degrees */
function ev(r,rho) = [
                      r/cos(rho),
                      grad(tan(rho)-radian(rho))
                      ];

/* Ball Gradient function
 Returns the azimuth angle of a bulb
 theta0 = polar angle of the cone, at the cutting edge of the large ball unrolls the involute
 theta = polar angle for which the azimuth angle of the involute is to be calculated */
function ball_ev(theta0,theta) = 1/sin(theta0)*acos(cos(theta)/cos(theta0))-acos(tan(theta0)/tan(theta));

/* Converts spherical coordinates to Cartesian
 Format: radius, theta, phi; theta = angle to z-axis, phi = angle to x-axis on xy-plane */
function ball_to_cart(vect) = [
                                vect[0]*sin(vect[1])*cos(vect[2]),
                                vect[0]*sin(vect[1])*sin(vect[2]),
                                vect[0]*cos(vect[1])
                                ];

/* checks if a number is_even
 = 1, if yes
 = 0 if the number is not straight */
function isstraight(number) =
(number == floor(number/2)*2) ? 1 : 0;

/* greatest common divisor
 according to Euclidean algorithm.
 Sorting: a must be greater than b */
function ggt(a,b) =
a%b == 0 ? b : ggt(b,a%b);

/* Polar function with polar angle and two variables */
function spiral(a, r0, phi) =
a*phi + r0;

/* Copy and spin a body */
module copy(vect, number, distance, corner){
    for(i = [0:number-1]){
        translate(v=vect*distance*i)
        rotate(a=i*corner, v = [0,0,1])
        children(0);
    }
}

/* Rack
 modul = height of the tooth tip above the rolling line
 length = length of the rack
 height = height of the rack to the pitch line
 width = width of a tooth
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the rack transverse axis; 0 ° = spur toothing */
module rack(modul, length, height, width, pressure_angle = 20, helix_angle = 0) {
    
    // Dimension calculations
    modul=modul*(1-play);
    c = modul / 6;                                              // head play
    mx = modul/cos(helix_angle);                          // Diagonal skewed module in x direction
    a = 2*mx*tan(pressure_angle)+c*tan(pressure_angle);       // flank width
    b = pi*mx/2-2*mx*tan(pressure_angle);                      // head width
    x = width*tan(helix_angle);                          // shift the top in the x direction by helix angle
    nz = ceil((length+abs(2*x))/(pi*mx));                       // Number of teeth
    
    translate([-pi*mx*(nz-1)/2-a-b/2,-modul,0]){
        intersection(){                                         // Creates a prism that fits into a box geometry
            copy([1,0,0], nz, pi*mx, 0){
                polyhedron(
                           points=[[0,-c,0], [a,2*modul,0], [a+b,2*modul,0], [2*a+b,-c,0], [pi*mx,-c,0], [pi*mx,modul-height,0], [0,modul-height,0], // bottom
                                   [0+x,-c,width], [a+x,2*modul,width], [a+b+x,2*modul,width], [2*a+b+x,-c,width], [pi*mx+x,-c,width], [pi*mx+x,modul-height,width], [0+x,modul-height,width]],   // top
                           faces=[[6,5,4,3,2,1,0],                     // bottom
                                  [1,8,7,0],
                                  [9,8,1,2],
                                  [10,9,2,3],
                                  [11,10,3,4],
                                  [12,11,4,5],
                                  [13,12,5,6],
                                  [7,13,6,0],
                                  [7,8,9,10,11,12,13],                    // top
                                  ]
                           );
            };
            translate([abs(x),-height+modul-0.5,-0.5]){
                cube([length,height+modul+1,width+1]);          // cuboid, which includes the volume of the rack
            }
        };
    };
}

/* Spur gear
 modul = height of the tooth tip over the pitch circle
 tooth_number = number of wheel teeth
 width = tooth width
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the axis of rotation; 0 ° = spur toothing
 optimized = holes for material / weight saving resp. Create surface enhancement if geometry allows */
module spur_gear(modul, tooth_number, width, drilling, pressure_angle = 20, helix_angle = 0, optimized = true) {
    
    // Dimensions-calculation
    d = modul * tooth_number;                                           // pitch circle diameter
    r = d / 2;                                                      // pitch circle radius
    alpha_front = atan(tan(pressure_angle)/cos(helix_angle));// helix angle in frontal section
    db = d * cos(alpha_front);                                      // base circle diameter
    rb = db / 2;                                                    // base circle radius
    da = (modul <1)? d + modul * 2.2 : d + modul * 2;               // tip diameter according to DIN 58400 resp. DIN 867
    ra = da / 2;                                                    // tip circle radius
    c =  (tooth_number <3)? 0 : modul/6;                                // head play
    df = d - 2 * (modul + c);                                       // root diameter
    rf = df / 2;                                                    // root radius
    rho_ra = acos(rb/ra);                                           // maximum roll-off angle;
    // involute starts on the base circle and ends at the tip circle
    rho_r = acos(rb/r);                                             // rolling angle at pitch circle;
    // involute starts on the base circle and ends at the tip circle
    phi_r = grad(tan(rho_r)-radian(rho_r));                         // angle to point of involute on pitch circle
    gamma = rad*width/(r*tan(90-helix_angle));               // torsion angle for extrusion
    step = rho_ra/16;                                            // involute is divided into 16 pieces
    tau = 360/tooth_number;                                             // pitch angle
    
    r_hole = (2*rf - drilling)/8;                                    // Radius of holes for material / weight savings
    rm = drilling/2+2*r_hole;                                        // distance of the axes of the holes from the main axis
    z_hole = floor(2*pi*rm/(3*r_hole));                             // Number of holes for material / weight savings
    
    optimized = (optimized && r >= width*1.5 && d > 2*drilling);    // is optimization useful?
    
    // drawing
    union(){
        rotate([0,0,-phi_r-90*(1-play)/tooth_number]){                     // center tooth on x-axis;
            //  makes alignment with other wheels easier
            
            linear_extrude(height = width, twist = gamma){
                difference(){
                    union(){
                        tooth_wide = (180*(1-play))/tooth_number+2*phi_r;
                        circle(rf);                                     // footer
                        for (rot = [0:tau:360]){
                            rotate (rot){                               // copy and rotate "number of teeth"
                                polygon(concat(                         // tooth
                                               [[0,0]],                            // Tooth segment starts and ends in origin
                                               [for (rho = [0:step:rho_ra])     // from zero degrees (base circle)
                                                // to maximum involute angle (top circle)
                                                pole_to_cart(ev(rb,rho))],       // First involute flank
                                               
                                               [pole_to_cart(ev(rb,rho_ra))],       // point of the involute on top circle
                                               
                                               [for (rho = [rho_ra:-step:0])    // of maximum involute angle (top circle)
                                                // to zero degrees (base circle)
                                                pole_to_cart([ev(rb,rho)[0], tooth_wide-ev(rb,rho)[1]])]
                                               // Second involute flank
                                               // (180 * (1-play)) instead of 180 degrees,
                                               // to allow play on the flanks
                                               )
                                        );
                            }
                        }
                    }
                    circle(r = rm+r_hole*1.49);                         // "drilling"
                }
            }
        }
        // with material savings
        if (optimized) {
            linear_extrude(height = width){
                difference(){
                    circle(r = (drilling+r_hole)/2);
                    circle(r = drilling/2);                          // drilling
                }
            }
            linear_extrude(height = (width-r_hole/2 < width*2/3) ? width*2/3 : width-r_hole/2){
                difference(){
                    circle(r=rm+r_hole*1.51);
                    union(){
                        circle(r=(drilling+r_hole)/2);
                        for (i = [0:1:z_hole]){
                            translate(ball_to_cart([rm,90,i*360/z_hole]))
                            circle(r = r_hole);
                        }
                    }
                }
            }
        }
        // without material savings
        else {
            linear_extrude(height = width){
                difference(){
                    circle(r = rm+r_hole*1.51);
                    circle(r = drilling/2);
                }
            }
        }
    }
}

/* Arrow wheel; uses the module "spur_gear"
 modul = height of the tooth tip over the pitch circle
 tooth_number = number of wheel teeth
 width = tooth width
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the axis of rotation, standard value = 0 ° (straight toothing)
 optimized = holes for material / weight saving */
module arrow_gear(modul, tooth_number, width, drilling, pressure_angle = 20, helix_angle=0, optimized=true){
    
    width = width/2;
    d = modul * tooth_number;                                           // pitch circle diameter
    r = d / 2;                                                      // pitch circle radius
    c =  (tooth_number <3)? 0 : modul/6;                                // head play
    
    df = d - 2 * (modul + c);                                       // root diameter
    rf = df / 2;                                                    // root radius
    
    r_hole = (2*rf - drilling)/8;                                    // Radius of holes for material / weight savings
    rm = drilling/2+2*r_hole;                                        // distance of the axes of the holes from the main axis
    z_hole = floor(2*pi*rm/(3*r_hole));                             // Number of holes for material / weight savings
    
    optimized = (optimized && r >= width*3 && d > 2*drilling);      // is optimization useful?
    
    translate([0,0,width]){
        union(){
            spur_gear(modul, tooth_number, width, 2*(rm+r_hole*1.49), pressure_angle, helix_angle, false);      // bottom half
            mirror([0,0,1]){
                spur_gear(modul, tooth_number, width, 2*(rm+r_hole*1.49), pressure_angle, helix_angle, false);  // top half
            }
        }
    }
    // with material savings
    if (optimized) {
        linear_extrude(height = width*2){
            difference(){
                circle(r = (drilling+r_hole)/2);
                circle(r = drilling/2);                          // drilling
            }
        }
        linear_extrude(height = (2*width-r_hole/2 < 1.33*width) ? 1.33*width : 2*width-r_hole/2){ //width*4/3
            difference(){
                circle(r=rm+r_hole*1.51);
                union(){
                    circle(r=(drilling+r_hole)/2);
                    for (i = [0:1:z_hole]){
                        translate(ball_to_cart([rm,90,i*360/z_hole]))
                        circle(r = r_hole);
                    }
                }
            }
        }
    }
    // without material savings
    else {
        linear_extrude(height = width*2){
            difference(){
                circle(r = rm+r_hole*1.51);
                circle(r = drilling/2);
            }
        }
    }
}

/* rack and wheel
 modul = height of the tooth tip over the pitch circle
 length_bar = length of the rack
 number of teeth_rad = number of wheel teeth
 height_bar = height of the rack to the pitch line
 bore_rad = diameter of the central bore of the spur gear
 width = width of a tooth
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the axis of rotation, standard value = 0 ° (straight toothing) */
module rack_and_pinion (modul, rod_length, num_of_teeth, height_rod, borehole_rad, width, pressure_angle=20, helix_angle=0, assembled=true, optimized=true) {
    
    distance = assembled? modul*num_of_teeth/2 : modul*num_of_teeth;
    
    rack(modul, rod_length, height_rod, width, pressure_angle, -helix_angle);
    translate([0,distance,0])
    rotate(a=360/num_of_teeth)
    spur_gear (modul, num_of_teeth, width, borehole_rad, pressure_angle, helix_angle, optimized);
}

/* Ring gear
 modul = height of the tooth tip over the pitch circle
 tooth_number = number of wheel teeth
 width = tooth width
 border width = width of the border from root circle
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the axis of rotation, standard value = 0 ° (straight toothing) */
module ring_gear(modul, tooth_number, width, edge_width, pressure_angle = 20, helix_angle = 0) {
    
    // Dimension calculations
    ha = (tooth_number >= 20) ? 0.02 * atan((tooth_number/15)/pi) : 0.6;    // shortening factor tooth head height
    d = modul * tooth_number;                                           // pitch circle diameter
    r = d / 2;                                                      // pitch circle radius
    alpha_front = atan(tan(pressure_angle)/cos(helix_angle));// helix angle in frontal section
    db = d * cos(alpha_front);                                      // base circle diameter
    rb = db / 2;                                                    //  base circle radius
    c = modul / 6;                                                  // head play
    da = (modul <1)? d + (modul+c) * 2.2 : d + (modul+c) * 2;       // tip diameter
    ra = da / 2;                                                    // tip circle radius
    df = d - 2 * modul * ha;                                        // root diameter
    rf = df / 2;                                                    // root radius
    rho_ra = acos(rb/ra);                                           // maximum involute angle;
    // involute starts on the base circle and ends at the tip circle
    rho_r = acos(rb/r);                                             // involute angle at pitch circle;
    // involute starts on the base circle and ends at the tip circle
    phi_r = grad(tan(rho_r)-radian(rho_r));                         // angle to point of involute on pitch circle
    gamma = rad*width/(r*tan(90-helix_angle));               // torsion angle for extrusion
    step = rho_ra/16;                                            // involute is divided into 16 pieces
    tau = 360/tooth_number;                                             // pitch angle
    
    // drawing
    rotate([0,0,-phi_r-90*(1+play)/tooth_number])                      // center tooth on x-axis;
    // makes alignment with other wheels easier
    linear_extrude(height = width, twist = gamma){
        difference(){
            circle(r = ra + edge_width);                            // outer circle
            union(){
                tooth_wide = (180*(1+play))/tooth_number+2*phi_r;
                circle(rf);                                         // footer
                for (rot = [0:tau:360]){
                    rotate (rot) {                                  // copy and rotate "number of teeth"
                        polygon( concat(
                                        [[0,0]],
                                        [for (rho = [0:step:rho_ra])         // from zero degrees (base circle)
                                         // to maximum involute angle (top circle)
                                         pole_to_cart(ev(rb,rho))],
                                        [pole_to_cart(ev(rb,rho_ra))],
                                        [for (rho = [rho_ra:-step:0])        // from maximum involute angle (top circle)
                                         // to zero degrees (base circle)
                                         pole_to_cart([ev(rb,rho)[0], tooth_wide-ev(rb,rho)[1]])]
                                        // (180 * (1 + play)) instead of 180,
                                        // to allow play on the flanks
                                        )
                                );
                    }
                }
            }
        }
    }
    
    echo("outer diameter ring gear = ", 2*(ra + edge_width));
    
}

/* Arrow ring gear; uses the module "ring_gear"
 modul = height of the tooth tip over the cone
 tooth_number = number of wheel teeth
 width = tooth width
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the axis of rotation, standard value = 0 ° (straight toothing) */
module arrow_ring_gear(modul, tooth_number, width, edge_width, pressure_angle = 20, helix_angle = 0) {
    
    width = width / 2;
    translate([0,0,width])
    union(){
        ring_gear(modul, tooth_number, width, edge_width, pressure_angle, helix_angle);       // bottom half
        mirror([0,0,1])
        ring_gear(modul, tooth_number, width, edge_width, pressure_angle, helix_angle);   // upper half
    }
}

/* Planetary gear; uses the modules "arrow_gear" and "arrow_ring_gear"
 modul = height of the tooth tip over the cone
 num_teeth_sun = number of teeth of the sun gear
 num_teeth_planet = number of teeth of a planetary gear
 number_planets = number of planet gears. If null, the function will calculate the minimum number.
 width = tooth width
 border width = width of the border from root circle
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle to the axis of rotation, standard value = 0 ° (straight toothing)
 assembled =
 optimized = holes for material / weight saving resp. Create surface enhancement if geometry allows
 assembled = components assembled for construction or apart from 3D printing */
module planetary_gear(modul, num_teeth_sun, num_teeth_planet, number_planet, width, edge_width, drilling, pressure_angle=20, helix_angle=0, assembled=true, optimized=true){
    
    // Dimension calculations
    d_sun = modul*num_teeth_sun;                                     // pitch circle sun
    d_planet = modul*num_teeth_planet;                                   // pitch circle planet
    achsabstand = modul*(num_teeth_sun +  num_teeth_planet) / 2;        // Distance from sun gear / ring gear axis
    num_teeth_hohlrad = num_teeth_sun + 2*num_teeth_planet;              // Number of teeth of the ring gear
    d_hohlrad = modul*num_teeth_hohlrad;                                 // pitch circle ring gear
    
    rotate = isstraight(num_teeth_planet);                                // Does the sun gear have to be turned?
    
    n_max = floor(180/asin(modul*(num_teeth_planet)/(modul*(num_teeth_sun +  num_teeth_planet))));
    // Number of planet gears: at most as many as without
    // overlap possible
    
    // drawing
    rotate([0,0,180/num_teeth_sun*rotate]){
        arrow_gear (modul, num_teeth_sun, width, drilling, pressure_angle, -helix_angle, optimized);      // sun wheel
    }
    
    if (assembled){
        if(number_planet==0){
            list = [ for (n=[2 : 1 : n_max]) if ((((num_teeth_hohlrad+num_teeth_sun)/n)==floor((num_teeth_hohlrad+num_teeth_sun)/n))) n];
            number_planet = list[0];                                      // Determine Number of Planetary Wheels
            achsabstand = modul*(num_teeth_sun + num_teeth_planet)/2;      // Distance from sun gear / ring gear axis
            for(n=[0:1:number_planet-1]){
                translate(ball_to_cart([achsabstand,90,360/number_planet*n]))
                rotate([0,0,n*360*d_sun/d_planet])
                arrow_gear (modul, num_teeth_planet, width, drilling, pressure_angle, helix_angle); // planet wheels
            }
        }
        else{
            achsabstand = modul*(num_teeth_sun + num_teeth_planet)/2;       // Distance from sun gear / ring gear axis
            for(n=[0:1:number_planet-1]){
                translate(ball_to_cart([achsabstand,90,360/number_planet*n]))
                rotate([0,0,n*360*d_sun/(d_planet)])
                arrow_gear (modul, num_teeth_planet, width, drilling, pressure_angle, helix_angle); // planet wheels
            }
        }
    }
    else{
        planet_distance = num_teeth_hohlrad*modul/2+edge_width+d_planet;     // distance planets among each other
        for(i=[-(number_planet-1):2:(number_planet-1)]){
            translate([planet_distance, d_planet*i,0])
            arrow_gear (modul, num_teeth_planet, width, drilling, pressure_angle, helix_angle); // planet wheels
        }
    }
    
    arrow_ring_gear (modul, num_teeth_hohlrad, width, edge_width, pressure_angle, helix_angle); // ring gear
    
}

/* Bevel gear
 modul = height of the tooth tip above the cone; Specification for the outside of the cone
 tooth_number = number of wheel teeth
 part cone angle = (half) angle of the cone on which the other ring gear rolls
 tooth width = width of the teeth from the outside in the direction of the apex of the cone
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle, standard value = 0 ° */
module bevel_gear(modul, tooth_number, partial_cone_angle, tooth_wide, drilling, pressure_angle = 20, helix_angle=0) {
    
    // Dimension calculations
    d_outside = modul * tooth_number;                                    // pitch cone diameter on the cone base,
    // corresponds to the chord in a spherical section
    r_outside = d_outside / 2;                                        // Part cone radius on the cone base
    rg_outside = r_outside/sin(partial_cone_angle);                      // Big bevel radius for tooth outside, corresponds to the length of the cone flank;
    rg_inner = rg_outside - tooth_wide;                              // Big bevel radius for inside tooth
    r_inner = r_outside*rg_inner/rg_outside;
    alpha_front = atan(tan(pressure_angle)/cos(helix_angle));// helix angle in frontal section
    delta_b = asin(cos(alpha_front)*sin(partial_cone_angle));          // base cone angle
    da_outside = (modul <1)? d_outside + (modul * 2.2) * cos(partial_cone_angle): d_outside + modul * 2 * cos(partial_cone_angle);
    ra_outside = da_outside / 2;
    delta_a = asin(ra_outside/rg_outside);
    c = modul / 6;                                                  // head play
    df_outside = d_outside - (modul +c) * 2 * cos(partial_cone_angle);
    rf_outside = df_outside / 2;
    delta_f = asin(rf_outside/rg_outside);
    rkf = rg_outside*sin(delta_f);                                   // Radius of the cone foot
    height_f = rg_outside*cos(delta_f);                               // Height of the cone from the foot cone
    
    echo("Part cone diameter on the cone base = ", d_outside);
    
    // sizes for complementary truncated cone
    height_k = (rg_outside-tooth_wide)/cos(partial_cone_angle);          // height of the complementary cone for correct tooth length
    rk = (rg_outside-tooth_wide)/sin(partial_cone_angle);               // Foot radius of the complementary cone
    rfk = rk*height_k*tan(delta_f)/(rk+height_k*tan(delta_f));        // head radius of the cylinder for
    // Complementary truncated cone
    height_fk = rk*height_k/(height_k*tan(delta_f)+rk);                // height of the complementary truncated cone
    
    echo("Height bevel gear = ", height_f-height_fk);
    
    phi_r = ball_ev(delta_b, partial_cone_angle);                      // Angle to point of involute on partial cone
    
    // torsion angle gamma from helix angle
    gamma_g = 2*atan(tooth_wide*tan(helix_angle)/(2*rg_outside-tooth_wide));
    gamma = 2*asin(rg_outside/r_outside*sin(gamma_g/2));
    
    step = (delta_a - delta_b)/16;
    tau = 360/tooth_number;                                             // pitch angle
    start = (delta_b > delta_f) ? delta_b : delta_f;
    mirror_point = (180*(1-play))/tooth_number+2*phi_r;
    
    // Zeichnung
    rotate([0,0,phi_r+90*(1-play)/tooth_number]){                      //center tooth on x-axis;
        // makes alignment with other wheels easier
        translate([0,0,height_f]) rotate(a=[0,180,0]){
            union(){
                translate([0,0,height_f]) rotate(a=[0,180,0]){                               // truncated cone
                    difference(){
                        linear_extrude(height=height_f-height_fk, scale=rfk/rkf) circle(rkf*1.001); // 1 per mil overlap with tooth root
                        translate([0,0,-1]){
                            cylinder(h = height_f-height_fk+2, r = drilling/2);                // Drilling
                        }
                    }
                }
                for (rot = [0:tau:360]){
                    rotate (rot) {                                                          // copy and rotate "number of teeth"
                        union(){
                            if (delta_b > delta_f){
                                // tooth root
                                edge_below = 1*mirror_point;
                                edge_above = ball_ev(delta_f, start);
                                polyhedron(
                                           points = [
                                                     ball_to_cart([rg_outside, start*1.001, edge_below]),    // 1 per mil overlap with tooth
                                                     ball_to_cart([rg_inner, start*1.001, edge_below+gamma]),
                                                     ball_to_cart([rg_inner, start*1.001, mirror_point-edge_below+gamma]),
                                                     ball_to_cart([rg_outside, start*1.001, mirror_point-edge_below]),
                                                     ball_to_cart([rg_outside, delta_f, edge_below]),
                                                     ball_to_cart([rg_inner, delta_f, edge_below+gamma]),
                                                     ball_to_cart([rg_inner, delta_f, mirror_point-edge_below+gamma]),
                                                     ball_to_cart([rg_outside, delta_f, mirror_point-edge_below])
                                                     ],
                                           faces = [[0,1,2],[0,2,3],[0,4,1],[1,4,5],[1,5,2],[2,5,6],[2,6,3],[3,6,7],[0,3,7],[0,7,4],[4,6,5],[4,7,6]],
                                           convexity =1
                                           );
                            }
                            // tooth
                            for (delta = [start:step:delta_a-step]){
                                edge_below = ball_ev(delta_b, delta);
                                edge_above = ball_ev(delta_b, delta+step);
                                polyhedron(
                                           points = [
                                                     ball_to_cart([rg_outside, delta, edge_below]),
                                                     ball_to_cart([rg_inner, delta, edge_below+gamma]),
                                                     ball_to_cart([rg_inner, delta, mirror_point-edge_below+gamma]),
                                                     ball_to_cart([rg_outside, delta, mirror_point-edge_below]),
                                                     ball_to_cart([rg_outside, delta+step, edge_above]),
                                                     ball_to_cart([rg_inner, delta+step, edge_above+gamma]),
                                                     ball_to_cart([rg_inner, delta+step, mirror_point-edge_above+gamma]),
                                                     ball_to_cart([rg_outside, delta+step, mirror_point-edge_above])
                                                     ],
                                           faces = [[0,1,2],[0,2,3],[0,4,1],[1,4,5],[1,5,2],[2,5,6],[2,6,3],[3,6,7],[0,3,7],[0,7,4],[4,6,5],[4,7,6]],
                                           convexity =1
                                           );
                            }
                        }
                    }
                }
            }
        }
    }
}

/* Arrow bevel gear; uses the module "bevel_gear"
 modul = height of the tooth tip over the pitch circle
 tooth_number = number of wheel teeth
 Part cone angle, tooth width
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle, standard value = 0 ° */
module bevel_arrow_gear(modul, tooth_number, partial_cone_angle, tooth_wide, drilling, pressure_angle = 20, helix_angle=0){
    
    // Dimension calculations
    
    tooth_wide = tooth_wide / 2;
    
    d_outside = modul * tooth_number;                                // pitch cone diameter on the cone base,
    // corresponds to the chord in a spherical section
    r_outside = d_outside / 2;                                    // Part cone radius on the cone base
    rg_outside = r_outside/sin(partial_cone_angle);                  // big taper radius, corresponds to the length of the cone flank;
    c = modul / 6;                                              // head play
    df_outside = d_outside - (modul +c) * 2 * cos(partial_cone_angle);
    rf_outside = df_outside / 2;
    delta_f = asin(rf_outside/rg_outside);
    height_f = rg_outside*cos(delta_f);                           // Height of the cone from the foot cone
    
    // torsion angle gamma from helix angle
    gamma_g = 2*atan(tooth_wide*tan(helix_angle)/(2*rg_outside-tooth_wide));
    gamma = 2*asin(rg_outside/r_outside*sin(gamma_g/2));
    
    echo("pitch cone diameter on the cone base = ", d_outside);
    
    // sizes for complementary truncated cone
    height_k = (rg_outside-tooth_wide)/cos(partial_cone_angle);      // height of the complementary cone for correct tooth length
    rk = (rg_outside-tooth_wide)/sin(partial_cone_angle);           // Foot radius of the complementary cone
    rfk = rk*height_k*tan(delta_f)/(rk+height_k*tan(delta_f));    // head radius of the cylinder for
    // Complementary truncated cone
    height_fk = rk*height_k/(height_k*tan(delta_f)+rk);            // height of the complementary truncated cone
    
    modul_inner = modul*(1-tooth_wide/rg_outside);
    
    union(){
        bevel_gear(modul, tooth_number, partial_cone_angle, tooth_wide, drilling, pressure_angle, helix_angle);        // bottom half
        translate([0,0,height_f-height_fk])
        rotate(a=-gamma,v=[0,0,1])
        bevel_gear(modul_inner, tooth_number, partial_cone_angle, tooth_wide, drilling, pressure_angle, -helix_angle); // top half
    }
}

/* Spiral bevel gear; uses the module "bevel_gear"
 modul = height of the tooth tip over the pitch circle
 tooth_number = number of wheel teeth
 height = height of the gear
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle, standard value = 0 ° */

//ACK NOTE: unused function???? spiralkegelrad = spiral bevel
module spiralkegelrad(modul, tooth_number, partial_cone_angle, tooth_wide, drilling, pressure_angle = 20, helix_angle=30){
    
    steps = 16;
    
    // Dimension calculations
    
    b = tooth_wide / steps;
    d_outside = modul * tooth_number;                                // pitch cone diameter on the cone base,
    // corresponds to the chord in a spherical section
    r_outside = d_outside / 2;                                    // Part cone radius on the cone base
    rg_outside = r_outside/sin(partial_cone_angle);                  // big taper radius, corresponds to the length of the cone flank;
    rg_center = rg_outside-tooth_wide/2;
    
    echo("Part cone diameter on the cone base = ", d_outside);
    
    a=tan(helix_angle)/rg_center;
    
    union(){
        for(i=[0:1:steps-1]){
            r = rg_outside-i*b;
            helix_angle = a*r;
            modul_r = modul-b*i/rg_outside;
            translate([0,0,b*cos(partial_cone_angle)*i])
            
            rotate(a=-helix_angle*i,v=[0,0,1])
            bevel_gear(modul_r, tooth_number, partial_cone_angle, b, drilling, pressure_angle, helix_angle);   // upper half
        }
    }
}

/* Bevel gear pair with any axis angle; uses the module "bevel_gear"
 modul = height of the tooth tip above the cone; Specification for the outside of the cone
 num_of_teeth = number of wheel teeth on the wheel
 Number of teeth = number of gear teeth on the pinion
 Axle Angle = Angle between the axles of the wheel and pinion
 tooth width = width of the teeth from the outside in the direction of the apex of the cone
 bore_rad = diameter of the center bore of the wheel
 Bore_pinion = diameter of the center holes of the pinion
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle, standard value = 0 °
 assembled = components assembled for construction or apart from 3D printing */
module bevel_gear_pair(modul, num_of_teeth, num_teeth_pinion, axis_angle=90, tooth_wide, borehole_rad, borehole_pinion, pressure_angle=20, helix_angle=0, assembled=true){
    
    // Dimension calculations
    r_rad = modul*num_of_teeth/2;                           // Part cone radius of the wheel
    delta_rad = atan(sin(axis_angle)/(num_teeth_pinion/num_of_teeth+cos(axis_angle)));   // cone angle of the wheel
    delta_pinion = atan(sin(axis_angle)/(num_of_teeth/num_teeth_pinion+cos(axis_angle)));// Cone angle of the pinion
    rg = r_rad/sin(delta_rad);                              // Radius of the big ball
    c = modul / 6;                                          // head play
    df_pinion = pi*rg*delta_pinion/90 - 2 * (modul + c);    // Taper diameter on the big ball
    rf_pinion = df_pinion / 2;                              // Foot cone radius on the big ball
    delta_f_pinion = rf_pinion/(pi*rg) * 180;               // head cone angle
    rkf_pinion = rg*sin(delta_f_pinion);                    // Radius of the cone foot
    height_f_pinion = rg*cos(delta_f_pinion);                // Height of the cone from the foot cone
    
    echo("Cone angle wheel = ", delta_rad);
    echo("Cone angle pinion = ", delta_pinion);
    
    df_rad = pi*rg*delta_rad/90 - 2 * (modul + c);          // Taper diameter on the big ball
    rf_rad = df_rad / 2;                                    // Foot cone radius on the big ball
    delta_f_rad = rf_rad/(pi*rg) * 180;                     // head cone angle
    rkf_rad = rg*sin(delta_f_rad);                          // Radius of the cone foot
    height_f_rad = rg*cos(delta_f_rad);                      // Height of the cone from the foot cone
    
    echo("Height wheel = ", height_f_rad);
    echo("Height pinion = ", height_f_pinion);
    
    rotate = isstraight(num_teeth_pinion);
    
    // drawing
    // rad
    rotate([0,0,180*(1-play)/num_of_teeth*rotate])
    bevel_gear(modul, num_of_teeth, delta_rad, tooth_wide, borehole_rad, pressure_angle, helix_angle);
    
    // pinion
    if (assembled)
        translate([-height_f_pinion*cos(90-axis_angle),0,height_f_rad-height_f_pinion*sin(90-axis_angle)])
        rotate([0,axis_angle,0])
        bevel_gear(modul, num_teeth_pinion, delta_pinion, tooth_wide, borehole_pinion, pressure_angle, -helix_angle);
    else
        translate([rkf_pinion*2+modul+rkf_rad,0,0])
        bevel_gear(modul, num_teeth_pinion, delta_pinion, tooth_wide, borehole_pinion, pressure_angle, -helix_angle);
}

/* Arrow-bevel gear pair with any axis angle; uses the module "bevel_arrow_gear"
 modul = height of the tooth tip above the cone; Specification for the outside of the cone
 num_of_teeth = number of wheel teeth on the wheel
 Number of teeth = number of gear teeth on the pinion
 Axle Angle = Angle between the axles of the wheel and pinion
 tooth width = width of the teeth from the outside in the direction of the apex of the cone
 bore_rad = diameter of the center bore of the wheel
 Bore_pinion = diameter of the center holes of the pinion
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 angle of inclination = helix angle, standard value = 0 °
 assembled = components assembled for construction or apart from 3D printing */
module bevel_arrow_gear_pair(modul, num_of_teeth, num_teeth_pinion, axis_angle=90, tooth_wide, borehole_rad, borehole_pinion, pressure_angle = 20, helix_angle=10, assembled=true){
    
    r_rad = modul*num_of_teeth/2;                           // Part cone radius of the wheel
    delta_rad = atan(sin(axis_angle)/(num_teeth_pinion/num_of_teeth+cos(axis_angle)));   // cone angle of the wheel
    delta_pinion = atan(sin(axis_angle)/(num_of_teeth/num_teeth_pinion+cos(axis_angle)));// Cone angle of the pinion
    rg = r_rad/sin(delta_rad);                              // Radius of the big ball
    c = modul / 6;                                          // head play
    df_pinion = pi*rg*delta_pinion/90 - 2 * (modul + c);    // Taper diameter on the big ball
    rf_pinion = df_pinion / 2;                              // Foot cone radius on the big ball
    delta_f_pinion = rf_pinion/(pi*rg) * 180;               // head cone angle
    rkf_pinion = rg*sin(delta_f_pinion);                    // Radius of the cone foot
    height_f_pinion = rg*cos(delta_f_pinion);                // Height of the cone from the foot cone
    
    echo("Cone angle wheel = ", delta_rad);
    echo("Bevel angle pinion = ", delta_pinion);
    
    df_rad = pi*rg*delta_rad/90 - 2 * (modul + c);          // Taper diameter on the big ball
    rf_rad = df_rad / 2;                                    // Foot cone radius on the big ball
    delta_f_rad = rf_rad/(pi*rg) * 180;                     // head cone angle
    rkf_rad = rg*sin(delta_f_rad);                          // Radius of the cone foot
    height_f_rad = rg*cos(delta_f_rad);                      // Height of the cone from the foot cone
    
    echo("Height wheel = ", height_f_rad);
    echo("Height pinion = ", height_f_pinion);
    
    rotate = isstraight(num_teeth_pinion);
    
    // Rad
    rotate([0,0,180*(1-play)/num_of_teeth*rotate])
    bevel_arrow_gear(modul, num_of_teeth, delta_rad, tooth_wide, borehole_rad, pressure_angle, helix_angle);
    
    // pinion
    if (assembled)
        translate([-height_f_pinion*cos(90-axis_angle),0,height_f_rad-height_f_pinion*sin(90-axis_angle)])
        rotate([0,axis_angle,0])
        bevel_arrow_gear(modul, num_teeth_pinion, delta_pinion, tooth_wide, borehole_pinion, pressure_angle, -helix_angle);
    else
        translate([rkf_pinion*2+modul+rkf_rad,0,0])
        bevel_arrow_gear(modul, num_teeth_pinion, delta_pinion, tooth_wide, borehole_pinion, pressure_angle, -helix_angle);
    
}

/*
 Archimedean screw.
 modul = height of the screw head over the part cylinder
 Number of gears = number of gears (teeth) of the worm
 length = length of the screw
 bore = diameter of the center hole
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 pitch angle = pitch angle of the worm, corresponds to 90 ° minus helix angle. Positive slope angle = clockwise.
 assembled = components assembled for construction or apart from 3D printing */
module worm(modul, transfer_coefficient, length, drilling, pressure_angle=20, gradient_angle, assembled=true){
    
    // Dimension calculations
    c = modul / 6;                                              // head play
    r = modul*transfer_coefficient/(2*sin(gradient_angle));                // partial cylinder radius
    rf = r - modul - c;                                         // Foot cylinder radius
    a = modul*transfer_coefficient/(90*tan(pressure_angle));               // spiral parameters
    tau_max = 180/transfer_coefficient*tan(pressure_angle);                // Angle from foot to head in the normal
    gamma = -rad*length/((rf+modul+c)*tan(gradient_angle));    // torsion angle for extrusion
    
    step = tau_max/16;
    
    // Drawing: extrude with twist a surface enclosed by two Archimedean spirals
    if (assembled) {
        rotate([0,0,tau_max]){
            linear_extrude(height = length, center = false, convexity = 10, twist = gamma){
                difference(){
                    union(){
                        for(i=[0:1:transfer_coefficient-1]){
                            polygon(
                                    concat(
                                           [[0,0]],
                                           
                                           // rising tooth flank
                                           [for (tau = [0:step:tau_max])
                                            pole_to_cart([spiral(a, rf, tau), tau+i*(360/transfer_coefficient)])],
                                           
                                           // tooth head
                                           [for (tau = [tau_max:step:180/transfer_coefficient])
                                            pole_to_cart([spiral(a, rf, tau_max), tau+i*(360/transfer_coefficient)])],
                                           
                                           // descending tooth flank
                                           [for (tau = [180/transfer_coefficient:step:(180/transfer_coefficient+tau_max)])
                                            pole_to_cart([spiral(a, rf, 180/transfer_coefficient+tau_max-tau), tau+i*(360/transfer_coefficient)])]
                                           )
                                    );
                        }
                        circle(rf);
                    }
                    circle(drilling/2); // center hole
                }
            }
        }
    }
    else {
        difference(){
            union(){
                translate([1,r*1.5,0]){
                    rotate([90,0,90])
                    worm(modul, transfer_coefficient, length, drilling, pressure_angle, gradient_angle, assembled=true);
                }
                translate([length+1,-r*1.5,0]){
                    rotate([90,0,-90])
                    worm(modul, transfer_coefficient, length, drilling, pressure_angle, gradient_angle, assembled=true);
                }
            }
            translate([length/2+1,0,-(r+modul+1)/2]){
                cube([length+2,3*r+2*(r+modul+1),r+modul+1], center = true);
            }
        }
    }
}

/*
 Calculates a worm wheel set. The worm wheel is an ordinary track gear without globoidgeometry.
 modul = height of the screw head above the partial cylinder or the tooth head above the pitch circle
 tooth_number = Number of wheel teeth
 Number of gears (teeth) of the screw
 width = tooth width
 length = length of the screw
 bore_screw = diameter of the center hole of the screw
 bore_rad = diameter of the central bore of the spur gear
 pressure_angle = pressure angle, standard value = 20 ° according to DIN 867. Should not be greater than 45 °.
 pitch angle = pitch angle of the worm to 90 ° bevel angle. Positive slope angle = clockwise.
 optimized = Holes for material / weight savings
 assembled = Components assembled for 3D printing */
module worm_gear(modul, tooth_number, transfer_coefficient, width, length, borehole_wormgear, borehole_rad, pressure_angle=20, gradient_angle, optimized=true, assembled=true, show_spur=1, show_worm=1){
    
    c = modul / 6;                                              // head play
    r_wormgear = modul*transfer_coefficient/(2*sin(gradient_angle));       // partial cylinder radius worm
    r_rad = modul*tooth_number/2;                                   // Part cone radius Spur gear
    rf_wormgear = r_wormgear - modul - c;                       // Foot cylinder radius
    gamma = -90*width*sin(gradient_angle)/(pi*r_rad);         // Rotation angle of the spur gear
    tooth_distance = modul*pi/cos(gradient_angle);                // tooth spacing in transverse section
    x = isstraight(transfer_coefficient)? 0.5 : 1;
    
    if (assembled) {
        if(show_worm)
            translate([r_wormgear,(ceil(length/(2*tooth_distance))-x)*tooth_distance,0])
            rotate([90,180/transfer_coefficient,0])
            worm(modul, transfer_coefficient, length, borehole_wormgear, pressure_angle, gradient_angle, assembled);
        
        if(show_spur)
            translate([-r_rad,0,-width/2])
            rotate([0,0,gamma])
            spur_gear (modul, tooth_number, width, borehole_rad, pressure_angle, -gradient_angle, optimized);
    }
    else {
        if(show_worm)
            worm(modul, transfer_coefficient, length, borehole_wormgear, pressure_angle, gradient_angle, assembled);
        
        if(show_spur)
            translate([-2*r_rad,0,0])
            spur_gear (modul, tooth_number, width, borehole_rad, pressure_angle, -gradient_angle, optimized);
    }
}

// rack (module = 1, length = 30, height = 5, width = 5, pressure_angle = 20, angle of twist = 20);

// spur_gear (modul = 1, tooth_number = 30, width = 5, hole = 4, pressure_angle = 20, angle = 20, optimized = true);

// arrow_gear (modul = 1, tooth_number = 30, width = 5, hole = 4, pressure_angle = 20, angle = 30, optimized = true);

// rack_and_rad (module = 1, length_bar = 50, number_of_rad = 30, height_bar = 4, bore_rad = 4, width = 5, pressure_angle = 20, angle = 0, together_built = true, optimized = true);

// ring_gear (modul = 1, tooth_number = 30, width = 5, border = 3, pressure_angle = 20, angle = 20);

// arrow_ring_gear (modul = 1, tooth_number = 30, width = 5, border = 3, pressure_angle = 20, angle = 30);

// planetary_gear (modul = 1, tooth_number_sun = 16, tooth_plan_planet = 9, number_planets = 5, width = 5, border = 3, hole = 4, pressure_angle = 20, angle = 30, together_built = true, optimized = true);

// bevel_gear (modul = 1, tooth_number = 30, angle = 45, tooth width = 5, hole = 4, pressure_angle = 20, angle = 20);

// bevel_arrow_gear (modul = 1, tooth_number = 30, angle = 45, tooth width = 5, bore = 4, pressure_angle = 20, angle = 30);

// bevel_gear_pair (modul = 1, number of teeth = 30, number of teeth = 11, axis angle = 100, tooth width = 5, bore = 4, pressure_angle = 20, angle = 20, together_built = true);

// bevel_arrow_gear_pair (modul = 1, number of teeth = 30, number of teeth = 11, axis = 100, tooth = 5, bore = 4, pressure_angle = 20, angle = 30, together_built = true);

// worm (module = 1, number of steps = 2, length = 15, hole = 4, pressure_angle = 20, angle = 10, together_built = true);

// worm_gear (modul = 1, tooth_number = 30, aisle = 2, width = 8, length = 20, bore_screw = 4, bore_rad = 4, pressure_angle = 20, pitch = 10, optimized = 1, collect_built = 1, show_spur = 1, show_worm = 1);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// rack(modul=1, length=30, height=5, width=5, pressure_angle=20, helix_angle=20);

//spur_gear (modul=1, tooth_number=30, width=5, drilling=4, pressure_angle=20, helix_angle=20, optimized=true);

//arrow_gear (modul=1, tooth_number=30, width=5, drilling=4, pressure_angle=20, helix_angle=30, optimized=true);

//rack_and_pinion (modul=1, rod_length=50, num_of_teeth=30, height_rod=4, borehole_rad=4, width=5, pressure_angle=20, helix_angle=0, assembled=true, optimized=true);

//ring_gear (modul=1, tooth_number=30, width=5, edge_width=3, pressure_angle=20, helix_angle=20);

// arrow_ring_gear (modul=1, tooth_number=30, width=5, edge_width=3, pressure_angle=20, helix_angle=30);

planetary_gear(modul=1, num_teeth_sun=13, num_teeth_planet=11, number_planet=3, width=10, edge_width=5, drilling=3, pressure_angle=20, helix_angle=30, assembled=false, optimized=true);

//bevel_gear(modul=1, tooth_number=30,  partial_cone_angle=45, tooth_wide=5, drilling=4, pressure_angle=20, helix_angle=20);

// bevel_arrow_gear(modul=1, tooth_number=30, partial_cone_angle=45, tooth_wide=5, drilling=4, pressure_angle=20, helix_angle=30);

// bevel_gear_pair(modul=1, num_of_teeth=30, num_teeth_pinion=11, axis_angle=100, tooth_wide=5, drilling=4, pressure_angle = 20, helix_angle=20, assembled=true);

// bevel_arrow_gear_pair(modul=1, num_of_teeth=30, num_teeth_pinion=11, axis_angle=100, tooth_wide=5, drilling=4, pressure_angle = 20, helix_angle=30, assembled=true);

// worm(modul=1, transfer_coefficient=2, length=15, drilling=4, pressure_angle=20, gradient_angle=10, assembled=true);

//worm_gear(modul=1, tooth_number=30, transfer_coefficient=2, width=8, length=20, borehole_wormgear=4, borehole_rad=4, pressure_angle=20, gradient_angle=10, optimized=1, assembled=1, show_spur=1, show_worm=1);
