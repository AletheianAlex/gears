$fn = 96;

/* Library for Involute Gears, Screws and Racks

This library contains the following modules
- rack(modul, length, height, width, pressure_angle=20, helix_angle=0)
- spur_gear(modul, tooth_number, width, bore, pressure_angle=20, helix_angle=0, optimized=true)
- herringbone_gear(modul, tooth_number, width, bore, pressure_angle=20, helix_angle=0, optimized=true)
- rack_and_pinion (modul, rack_length, gear_teeth, rack_height, gear_bore, width, pressure_angle=20, helix_angle=0, together_built=true, optimized=true)
- ring_gear(modul, tooth_number, width, rim_width, pressure_angle=20, helix_angle=0)
- herringbone_ring_gear(modul, tooth_number, width, rim_width, pressure_angle=20, helix_angle=0)
- planetary_gear(modul, sun_teeth, planet_teeth, number_planets, width, rim_width, bore, pressure_angle=20, helix_angle=0, together_built=true, optimized=true)
- bevel_gear(modul, tooth_number,  teilkegelwinkel, tooth_width, bore, pressure_angle=20, helix_angle=0)
- bevel_herringbone_gear(modul, tooth_number, teilkegelwinkel, tooth_width, bore, pressure_angle=20, helix_angle=0)
- bevel_gear_pair(modul, gear_teeth, pinion_teeth, axis_angle=90, tooth_width, bore, pressure_angle = 20, helix_angle=0, together_built=true)
- bevel_herringbone_gear_pair(modul, gear_teeth, pinion_teeth, axis_angle=90, tooth_width, bore, pressure_angle = 20, helix_angle=0, together_built=true)
- worm(modul, thread_starts, length, bore, pressure_angle=20, lead_angle=10, together_built=true)
- worm_gear(modul, tooth_number, thread_starts, width, length, worm_bore, gear_bore, pressure_angle=20, lead_angle=0, optimized=true, together_built=true)

Examples of each module are commented out at the end of this file

Author:      Dr Jörg Janssen
Last Verified On:      1. June 2018
Version:    2.2
License:     Creative Commons - Attribution, Non Commercial, Share Alike

Permitted modules according to DIN 780:
0.05 0.06 0.08 0.10 0.12 0.16
0.20 0.25 0.3  0.4  0.5  0.6
0.7  0.8  0.9  1    1.25 1.5
2    2.5  3    4    5    6
8    10   12   16   20   25
32   40   50   60

*/


// General Variables
pi = 3.14159;
rad = 57.29578;
clearance = 0.05;   // clearance between teeth

/*  Converts Radians to Degrees */
function grad(pressure_angle) = pressure_angle*rad;

/*  Converts Degrees to Radians */
function radian(pressure_angle) = pressure_angle/rad;

/*  Converts 2D Polar Coordinates to Cartesian
    Format: radius, phi; phi = Angle to x-Axis on xy-Plane */
function polar_to_cartesian(polvect) = [
    polvect[0]*cos(polvect[1]),  
    polvect[0]*sin(polvect[1])
];

/*  Involutes-Function:
    Returns the Polar Coordinates of an Involute Circle
    r = Radius of the Base Circle
    rho = Rolling-angle in Degrees */
function ev(r,rho) = [
    r/cos(rho),
    grad(tan(rho)-radian(rho))
];

/*  Sphere-Involutes-Function
    Returns the Azimuth Angle of an Involute Sphere
    theta0 = Polarwinkel des Kegels, an dessen Schnittkante zur Großkugel die Evolvente abrollt
    theta = Polar Angle for which the Azimuth Angle of the Involute is to be calculated */
function kugelev(theta0,theta) = 1/sin(theta0)*acos(cos(theta)/cos(theta0))-acos(tan(theta0)/tan(theta));

/*  Converts Spherical Coordinates to Cartesian
    Format: radius, theta, phi; theta = Angle to z-Axis, phi = Angle to x-Axis on xy-Plane */
function sphere_to_cartesian(vect) = [
    vect[0]*sin(vect[1])*cos(vect[2]),  
    vect[0]*sin(vect[1])*sin(vect[2]),
    vect[0]*cos(vect[1])
];

/*  Check if a Number is even
    = 1, if so
    = 0, if the Number is not even */
function istgerade(zahl) =
    (zahl == floor(zahl/2)*2) ? 1 : 0;

/*  greatest common Divisor
    according to Euclidean Algorithm.
    Sorting: a must be greater than b */
function ggt(a,b) = 
    a%b == 0 ? b : ggt(b,a%b);

/*  Polar function with polar angle and two variables */
function spirale(a, r0, phi) =
    a*phi + r0; 

/*  Copy and rotate a Body */
module kopiere(vect, zahl, abstand, winkel){
    for(i = [0:zahl-1]){
        translate(v=vect*abstand*i)
            rotate(a=i*winkel, v = [0,0,1])
                children(0);
    }
}

/*  rack
    modul = Höhe des Zahnkopfes über der Wälzgeraden
    length = Länge der rack
    height = Höhe der rack bis zur Wälzgeraden
    width = Breite eines Zahns
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Zahnstangen-Querachse; 0° = Geradverzahnung */
module rack(modul, length, height, width, pressure_angle = 20, helix_angle = 0) {

    // Dimensions-Berechnungen
    modul=modul*(1-clearance);
    c = modul / 6;                                              // Kopfclearance
    mx = modul/cos(helix_angle);                          // Durch Schrägungswinkel verzerrtes modul in x-Richtung
    a = 2*mx*tan(pressure_angle)+c*tan(pressure_angle);       // Flankenbreite
    b = pi*mx/2-2*mx*tan(pressure_angle);                      // Kopfbreite
    x = width*tan(helix_angle);                          // Verschiebung der Oberseite in x-Richtung durch Schrägungswinkel
    nz = ceil((length+abs(2*x))/(pi*mx));                       // Anzahl der Zähne
    
    translate([-pi*mx*(nz-1)/2-a-b/2,-modul,0]){
        intersection(){                                         // Erzeugt ein Prisma, das in eine Quadergeometrie eingepasst wird
            kopiere([1,0,0], nz, pi*mx, 0){
                polyhedron(
                    points=[[0,-c,0], [a,2*modul,0], [a+b,2*modul,0], [2*a+b,-c,0], [pi*mx,-c,0], [pi*mx,modul-height,0], [0,modul-height,0], // Unterseite
                        [0+x,-c,width], [a+x,2*modul,width], [a+b+x,2*modul,width], [2*a+b+x,-c,width], [pi*mx+x,-c,width], [pi*mx+x,modul-height,width], [0+x,modul-height,width]],   // Oberseite
                    faces=[[6,5,4,3,2,1,0],                     // Unterseite
                        [1,8,7,0],
                        [9,8,1,2],
                        [10,9,2,3],
                        [11,10,3,4],
                        [12,11,4,5],
                        [13,12,5,6],
                        [7,13,6,0],
                        [7,8,9,10,11,12,13],                    // Oberseite
                    ]
                );
            };
            translate([abs(x),-height+modul-0.5,-0.5]){
                cube([length,height+modul+1,width+1]);          // Quader, der das Volumen der rack umfasst
            }   
        };
    };  
}

/*  Spur gear
    modul = Höhe des Zahnkopfes über dem Teilkreis
    tooth_number = Anzahl der Radzähne
    width = tooth_width
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Rotationsachse; 0° = Geradverzahnung
    optimized = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt */
module spur_gear(modul, tooth_number, width, bore, pressure_angle = 20, helix_angle = 0, optimized = true) {

    // Dimensions-Berechnungen  
    d = modul * tooth_number;                                           // Teilkreisdurchmesser
    r = d / 2;                                                      // Teilkreisradius
    alpha_spur = atan(tan(pressure_angle)/cos(helix_angle));// Schrägungswinkel im Stirnschnitt
    db = d * cos(alpha_spur);                                      // Grundkreisdurchmesser
    rb = db / 2;                                                    // Grundkreisradius
    da = (modul <1)? d + modul * 2.2 : d + modul * 2;               // Kopfkreisdurchmesser nach DIN 58400 bzw. DIN 867
    ra = da / 2;                                                    // Kopfkreisradius
    c =  (tooth_number <3)? 0 : modul/6;                                // Kopfclearance
    df = d - 2 * (modul + c);                                       // Fußkreisdurchmesser
    rf = df / 2;                                                    // Fußkreisradius
    rho_ra = acos(rb/ra);                                           // maximaler Abrollwinkel;
                                                                    // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
    rho_r = acos(rb/r);                                             // Abrollwinkel am Teilkreis;
                                                                    // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
    phi_r = grad(tan(rho_r)-radian(rho_r));                         // Winkel zum Punkt der Evolvente auf Teilkreis
    gamma = rad*width/(r*tan(90-helix_angle));               // Torsionswinkel für Extrusion
    schritt = rho_ra/16;                                            // Evolvente wird in 16 Stücke geteilt
    tau = 360/tooth_number;                                             // Teilungswinkel
    
    r_loch = (2*rf - bore)/8;                                    // Radius der Löcher für Material-/Gewichtsersparnis
    rm = bore/2+2*r_loch;                                        // Abstand der Achsen der Löcher von der Hauptachse
    z_loch = floor(2*pi*rm/(3*r_loch));                             // Anzahl der Löcher für Material-/Gewichtsersparnis
    
    optimized = (optimized && r >= width*1.5 && d > 2*bore);    // ist Optimierung sinnvoll?

    // Drawing
    union(){
        rotate([0,0,-phi_r-90*(1-clearance)/tooth_number]){                     // Zahn auf x-Achse zentrieren;
                                                                        // macht Ausrichtung mit anderen Rädern einfacher

            linear_extrude(height = width, twist = gamma){
                difference(){
                    union(){
                        tooth_width = (180*(1-clearance))/tooth_number+2*phi_r;
                        circle(rf);                                     // Fußkreis 
                        for (rot = [0:tau:360]){
                            rotate (rot){                               // "Zahnzahl-mal" kopieren und drehen
                                polygon(concat(                         // Zahn
                                    [[0,0]],                            // Zahnsegment beginnt und endet im Ursprung
                                    [for (rho = [0:schritt:rho_ra])     // von null Grad (Grundkreis)
                                                                        // bis maximalen Evolventenwinkel (Kopfkreis)
                                        polar_to_cartesian(ev(rb,rho))],       // Erste Evolventen-Flanke

                                    [polar_to_cartesian(ev(rb,rho_ra))],       // Punkt der Evolvente auf Kopfkreis

                                    [for (rho = [rho_ra:-schritt:0])    // von maximalen Evolventenwinkel (Kopfkreis)
                                                                        // bis null Grad (Grundkreis)
                                        polar_to_cartesian([ev(rb,rho)[0], tooth_width-ev(rb,rho)[1]])]
                                                                        // Zweite Evolventen-Flanke
                                                                        // (180*(1-clearance)) statt 180 Grad,
                                                                        // um clearance an den Flanken zu erlauben
                                    )
                                );
                            }
                        }
                    }           
                    circle(r = rm+r_loch*1.49);                         // "bore"
                }
            }
        }
        // mit Materialersparnis
        if (optimized) {
            linear_extrude(height = width){
                difference(){
                        circle(r = (bore+r_loch)/2);
                        circle(r = bore/2);                          // bore
                    }
                }
            linear_extrude(height = (width-r_loch/2 < width*2/3) ? width*2/3 : width-r_loch/2){
                difference(){
                    circle(r=rm+r_loch*1.51);
                    union(){
                        circle(r=(bore+r_loch)/2);
                        for (i = [0:1:z_loch]){
                            translate(sphere_to_cartesian([rm,90,i*360/z_loch]))
                                circle(r = r_loch);
                        }
                    }
                }
            }
        }
        // ohne Materialersparnis
        else {
            linear_extrude(height = width){
                difference(){
                    circle(r = rm+r_loch*1.51);
                    circle(r = bore/2);
                }
            }
        }
    }
}

/*  Herringbone; uses the module "spur_gear"
    modul = Höhe des Zahnkopfes über dem Teilkreis
    tooth_number = Anzahl der Radzähne
    width = tooth_width
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung)
    optimized = Löcher zur Material-/Gewichtsersparnis */
module herringbone_gear(modul, tooth_number, width, bore, pressure_angle = 20, helix_angle=0, optimized=true){

    width = width/2;
    d = modul * tooth_number;                                           // Teilkreisdurchmesser
    r = d / 2;                                                      // Teilkreisradius
    c =  (tooth_number <3)? 0 : modul/6;                                // Kopfclearance

    df = d - 2 * (modul + c);                                       // Fußkreisdurchmesser
    rf = df / 2;                                                    // Fußkreisradius

    r_loch = (2*rf - bore)/8;                                    // Radius der Löcher für Material-/Gewichtsersparnis
    rm = bore/2+2*r_loch;                                        // Abstand der Achsen der Löcher von der Hauptachse
    z_loch = floor(2*pi*rm/(3*r_loch));                             // Anzahl der Löcher für Material-/Gewichtsersparnis
    
    optimized = (optimized && r >= width*3 && d > 2*bore);      // ist Optimierung sinnvoll?

    translate([0,0,width]){
        union(){
            spur_gear(modul, tooth_number, width, 2*(rm+r_loch*1.49), pressure_angle, helix_angle, false);      // untere Hälfte
            mirror([0,0,1]){
                spur_gear(modul, tooth_number, width, 2*(rm+r_loch*1.49), pressure_angle, helix_angle, false);  // obere Hälfte
            }
        }
    }
    // mit Materialersparnis
    if (optimized) {
        linear_extrude(height = width*2){
            difference(){
                    circle(r = (bore+r_loch)/2);
                    circle(r = bore/2);                          // bore
                }
            }
        linear_extrude(height = (2*width-r_loch/2 < 1.33*width) ? 1.33*width : 2*width-r_loch/2){ //width*4/3
            difference(){
                circle(r=rm+r_loch*1.51);
                union(){
                    circle(r=(bore+r_loch)/2);
                    for (i = [0:1:z_loch]){
                        translate(sphere_to_cartesian([rm,90,i*360/z_loch]))
                            circle(r = r_loch);
                    }
                }
            }
        }
    }
    // ohne Materialersparnis
    else {
        linear_extrude(height = width*2){
            difference(){
                circle(r = rm+r_loch*1.51);
                circle(r = bore/2);
            }
        }
    }
}

/*  rack and pinion
    modul = Höhe des Zahnkopfes über dem Teilkreis
    rack_length = Laenge der rack
    gear_teeth = Anzahl der Radzähne
    rack_height = Höhe der rack bis zur Wälzgeraden
    gear_bore = Durchmesser der Mittelbohrung des Stirnrads
    width = Breite eines Zahns
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module rack_and_pinion (modul, rack_length, gear_teeth, rack_height, gear_bore, width, pressure_angle=20, helix_angle=0, together_built=true, optimized=true) {

    abstand = together_built? modul*gear_teeth/2 : modul*gear_teeth;

    rack(modul, rack_length, rack_height, width, pressure_angle, -helix_angle);
    translate([0,abstand,0])
        rotate(a=360/gear_teeth)
            spur_gear (modul, gear_teeth, width, gear_bore, pressure_angle, helix_angle, optimized);
}

/*  ring gear
    modul = Höhe des Zahnkopfes über dem Teilkreis
    tooth_number = Anzahl der Radzähne
    width = tooth_width
    rim_width = Breite des Randes ab Fußkreis
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module ring_gear(modul, tooth_number, width, rim_width, pressure_angle = 20, helix_angle = 0) {

    // Dimensions-Berechnungen  
    ha = (tooth_number >= 20) ? 0.02 * atan((tooth_number/15)/pi) : 0.6;    // Verkürzungsfaktor Zahnkopfhöhe
    d = modul * tooth_number;                                           // Teilkreisdurchmesser
    r = d / 2;                                                      // Teilkreisradius
    alpha_spur = atan(tan(pressure_angle)/cos(helix_angle));// Schrägungswinkel im Stirnschnitt
    db = d * cos(alpha_spur);                                      // Grundkreisdurchmesser
    rb = db / 2;                                                    // Grundkreisradius
    c = modul / 6;                                                  // Kopfclearance
    da = (modul <1)? d + (modul+c) * 2.2 : d + (modul+c) * 2;       // Kopfkreisdurchmesser
    ra = da / 2;                                                    // Kopfkreisradius
    df = d - 2 * modul * ha;                                        // Fußkreisdurchmesser
    rf = df / 2;                                                    // Fußkreisradius
    rho_ra = acos(rb/ra);                                           // maximaler Evolventenwinkel;
                                                                    // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
    rho_r = acos(rb/r);                                             // Evolventenwinkel am Teilkreis;
                                                                    // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
    phi_r = grad(tan(rho_r)-radian(rho_r));                         // Winkel zum Punkt der Evolvente auf Teilkreis
    gamma = rad*width/(r*tan(90-helix_angle));               // Torsionswinkel für Extrusion
    schritt = rho_ra/16;                                            // Evolvente wird in 16 Stücke geteilt
    tau = 360/tooth_number;                                             // Teilungswinkel

    // Zeichnung
    rotate([0,0,-phi_r-90*(1+clearance)/tooth_number])                      // Zahn auf x-Achse zentrieren;
                                                                    // macht Ausrichtung mit anderen Rädern einfacher
    linear_extrude(height = width, twist = gamma){
        difference(){
            circle(r = ra + rim_width);                            // Außenkreis
            union(){
                tooth_width = (180*(1+clearance))/tooth_number+2*phi_r;
                circle(rf);                                         // Fußkreis 
                for (rot = [0:tau:360]){
                    rotate (rot) {                                  // "Zahnzahl-mal" kopieren und drehen
                        polygon( concat(
                            [[0,0]],
                            [for (rho = [0:schritt:rho_ra])         // von null Grad (Grundkreis)
                                                                    // bis maximaler Evolventenwinkel (Kopfkreis)
                                polar_to_cartesian(ev(rb,rho))],
                            [polar_to_cartesian(ev(rb,rho_ra))],
                            [for (rho = [rho_ra:-schritt:0])        // von maximaler Evolventenwinkel (Kopfkreis)
                                                                    // bis null Grad (Grundkreis)
                                polar_to_cartesian([ev(rb,rho)[0], tooth_width-ev(rb,rho)[1]])]
                                                                    // (180*(1+clearance)) statt 180,
                                                                    // um clearance an den Flanken zu erlauben
                            )
                        );
                    }
                }
            }
        }
    }

    echo("Ring Gear Outer Diamater = ", 2*(ra + rim_width));
    
}

/*  Herringbone Ring Gear; uses the Module "ring_gear"
    modul = Höhe des Zahnkopfes über dem Teilkegel
    tooth_number = Anzahl der Radzähne
    width = tooth_width
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module herringbone_ring_gear(modul, tooth_number, width, rim_width, pressure_angle = 20, helix_angle = 0) {

    width = width / 2;
    translate([0,0,width])
        union(){
        ring_gear(modul, tooth_number, width, rim_width, pressure_angle, helix_angle);       // untere Hälfte
        mirror([0,0,1])
            ring_gear(modul, tooth_number, width, rim_width, pressure_angle, helix_angle);   // obere Hälfte
    }
}

/*  Planetary Gear; uses the Modules "herringbone_gear" and "herringbone_ring_gear"
    modul = Höhe des Zahnkopfes über dem Teilkegel
    sun_teeth = Anzahl der Zähne des Sonnenrads
    planet_teeth = Anzahl der Zähne eines Planetenrads
    number_planets = Anzahl der Planetenräder. Wenn null, rechnet die Funktion die Mindestanzahl aus.
    width = tooth_width
    rim_width = Breite des Randes ab Fußkreis
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung)
    together_built = 
    optimized = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt
    together_built = Komponenten zusammengebaut für Konstruktion oder auseinander zum 3D-Druck */
module planetary_gear(modul, sun_teeth, planet_teeth, number_planets, width, rim_width, bore, pressure_angle=20, helix_angle=0, together_built=true, optimized=true){

    // Dimensions-Berechnungen
    d_sun = modul*sun_teeth;                                     // Teilkreisdurchmesser Sonne
    d_planet = modul*planet_teeth;                                   // Teilkreisdurchmesser Planeten
    achsabstand = modul*(sun_teeth +  planet_teeth) / 2;        // Abstand von Sonnenrad-/Hohlradachse und Planetenachse
    ring_teeth = sun_teeth + 2*planet_teeth;              // Anzahl der Zähne des Hohlrades
    d_ring = modul*ring_teeth;                                 // Teilkreisdurchmesser Hohlrad

    drehen = istgerade(planet_teeth);                                // Muss das Sonnenrad gedreht werden?
        
    n_max = floor(180/asin(modul*(planet_teeth)/(modul*(sun_teeth +  planet_teeth))));
                                                                        // Anzahl Planetenräder: höchstens so viele, wie ohne
                                                                        // Überlappung möglich

    // Zeichnung
    rotate([0,0,180/sun_teeth*drehen]){
        herringbone_gear (modul, sun_teeth, width, bore, pressure_angle, -helix_angle, optimized);      // Sonnenrad
    }

    if (together_built){
        if(number_planets==0){
            list = [ for (n=[2 : 1 : n_max]) if ((((ring_teeth+sun_teeth)/n)==floor((ring_teeth+sun_teeth)/n))) n];
            number_planets = list[0];                                      // Ermittele Anzahl Planetenräder
             achsabstand = modul*(sun_teeth + planet_teeth)/2;      // Abstand von Sonnenrad-/Hohlradachse
            for(n=[0:1:number_planets-1]){
                translate(sphere_to_cartesian([achsabstand,90,360/number_planets*n]))
                    rotate([0,0,n*360*d_sun/d_planet])
                        herringbone_gear (modul, planet_teeth, width, bore, pressure_angle, helix_angle); // Planetenräder
            }
       }
       else{
            achsabstand = modul*(sun_teeth + planet_teeth)/2;       // Abstand von Sonnenrad-/Hohlradachse
            for(n=[0:1:number_planets-1]){
                translate(sphere_to_cartesian([achsabstand,90,360/number_planets*n]))
                rotate([0,0,n*360*d_sun/(d_planet)])
                    herringbone_gear (modul, planet_teeth, width, bore, pressure_angle, helix_angle); // Planetenräder
            }
        }
    }
    else{
        planetenabstand = ring_teeth*modul/2+rim_width+d_planet;     // Abstand Planeten untereinander
        for(i=[-(number_planets-1):2:(number_planets-1)]){
            translate([planetenabstand, d_planet*i,0])
                herringbone_gear (modul, planet_teeth, width, bore, pressure_angle, helix_angle); // Planetenräder
        }
    }

    herringbone_ring_gear (modul, ring_teeth, width, rim_width, pressure_angle, helix_angle); // Hohlrad

}

/*  Bevel Gear
    modul = Höhe des Zahnkopfes über dem Teilkegel; Angabe für die Aussenseite des Kegels
    tooth_number = Anzahl der Radzähne
    teilkegelwinkel = (Halb)winkel des Kegels, auf dem das jeweils andere Hohlrad abrollt
    tooth_width = Breite der Zähne von der Außenseite in Richtung Kegelspitze
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel, Standardwert = 0° */
module bevel_gear(modul, tooth_number, teilkegelwinkel, tooth_width, bore, pressure_angle = 20, helix_angle=0) {

    // Dimensions-Berechnungen
    d_aussen = modul * tooth_number;                                    // Teilkegeldurchmesser auf der Kegelgrundfläche,
                                                                    // entspricht der Sehne im Kugelschnitt
    r_aussen = d_aussen / 2;                                        // Teilkegelradius auf der Kegelgrundfläche 
    rg_aussen = r_aussen/sin(teilkegelwinkel);                      // Großkegelradius für Zahn-Außenseite, entspricht der Länge der Kegelflanke;
    rg_innen = rg_aussen - tooth_width;                              // Großkegelradius für Zahn-Innenseite  
    r_innen = r_aussen*rg_innen/rg_aussen;
    alpha_spur = atan(tan(pressure_angle)/cos(helix_angle));// Schrägungswinkel im Stirnschnitt
    delta_b = asin(cos(alpha_spur)*sin(teilkegelwinkel));          // Grundkegelwinkel     
    da_aussen = (modul <1)? d_aussen + (modul * 2.2) * cos(teilkegelwinkel): d_aussen + modul * 2 * cos(teilkegelwinkel);
    ra_aussen = da_aussen / 2;
    delta_a = asin(ra_aussen/rg_aussen);
    c = modul / 6;                                                  // Kopfclearance
    df_aussen = d_aussen - (modul +c) * 2 * cos(teilkegelwinkel);
    rf_aussen = df_aussen / 2;
    delta_f = asin(rf_aussen/rg_aussen);
    rkf = rg_aussen*sin(delta_f);                                   // Radius des Kegelfußes
    height_f = rg_aussen*cos(delta_f);                               // Höhe des Kegels vom Fußkegel
    
    echo("Teilkegeldurchmesser auf der Kegelgrundfläche = ", d_aussen);
    
    // Größen für Komplementär-Kegelstumpf
    height_k = (rg_aussen-tooth_width)/cos(teilkegelwinkel);          // Höhe des Komplementärkegels für richtige Zahnlänge
    rk = (rg_aussen-tooth_width)/sin(teilkegelwinkel);               // Fußradius des Komplementärkegels
    rfk = rk*height_k*tan(delta_f)/(rk+height_k*tan(delta_f));        // Kopfradius des Zylinders für 
                                                                    // Komplementär-Kegelstumpf
    height_fk = rk*height_k/(height_k*tan(delta_f)+rk);                // height des Komplementär-Kegelstumpfs

    echo("Höhe Kegelrad = ", height_f-height_fk);
    
    phi_r = kugelev(delta_b, teilkegelwinkel);                      // Winkel zum Punkt der Evolvente auf Teilkegel
        
    // Torsionswinkel gamma aus Schrägungswinkel
    gamma_g = 2*atan(tooth_width*tan(helix_angle)/(2*rg_aussen-tooth_width));
    gamma = 2*asin(rg_aussen/r_aussen*sin(gamma_g/2));
    
    schritt = (delta_a - delta_b)/16;
    tau = 360/tooth_number;                                             // Teilungswinkel
    start = (delta_b > delta_f) ? delta_b : delta_f;
    mirrpoint = (180*(1-clearance))/tooth_number+2*phi_r;

    // Zeichnung
    rotate([0,0,phi_r+90*(1-clearance)/tooth_number]){                      // Zahn auf x-Achse zentrieren;
                                                                    // macht Ausrichtung mit anderen Rädern einfacher
        translate([0,0,height_f]) rotate(a=[0,180,0]){
            union(){
                translate([0,0,height_f]) rotate(a=[0,180,0]){                               // Kegelstumpf                          
                    difference(){
                        linear_extrude(height=height_f-height_fk, scale=rfk/rkf) circle(rkf*1.001); // 1 promille Überlappung mit Zahnfuß
                        translate([0,0,-1]){
                            cylinder(h = height_f-height_fk+2, r = bore/2);                // bore
                        }
                    }   
                }
                for (rot = [0:tau:360]){
                    rotate (rot) {                                                          // "Zahnzahl-mal" kopieren und drehen
                        union(){
                            if (delta_b > delta_f){
                                // Zahnfuß
                                flankenpunkt_unten = 1*mirrpoint;
                                flankenpunkt_oben = kugelev(delta_f, start);
                                polyhedron(
                                    points = [
                                        sphere_to_cartesian([rg_aussen, start*1.001, flankenpunkt_unten]),    // 1 promille Überlappung mit Zahn
                                        sphere_to_cartesian([rg_innen, start*1.001, flankenpunkt_unten+gamma]),
                                        sphere_to_cartesian([rg_innen, start*1.001, mirrpoint-flankenpunkt_unten+gamma]),
                                        sphere_to_cartesian([rg_aussen, start*1.001, mirrpoint-flankenpunkt_unten]),                               
                                        sphere_to_cartesian([rg_aussen, delta_f, flankenpunkt_unten]),
                                        sphere_to_cartesian([rg_innen, delta_f, flankenpunkt_unten+gamma]),
                                        sphere_to_cartesian([rg_innen, delta_f, mirrpoint-flankenpunkt_unten+gamma]),
                                        sphere_to_cartesian([rg_aussen, delta_f, mirrpoint-flankenpunkt_unten])                                
                                    ],
                                    faces = [[0,1,2],[0,2,3],[0,4,1],[1,4,5],[1,5,2],[2,5,6],[2,6,3],[3,6,7],[0,3,7],[0,7,4],[4,6,5],[4,7,6]],
                                    convexity =1
                                );
                            }
                            // Zahn
                            for (delta = [start:schritt:delta_a-schritt]){
                                flankenpunkt_unten = kugelev(delta_b, delta);
                                flankenpunkt_oben = kugelev(delta_b, delta+schritt);
                                polyhedron(
                                    points = [
                                        sphere_to_cartesian([rg_aussen, delta, flankenpunkt_unten]),
                                        sphere_to_cartesian([rg_innen, delta, flankenpunkt_unten+gamma]),
                                        sphere_to_cartesian([rg_innen, delta, mirrpoint-flankenpunkt_unten+gamma]),
                                        sphere_to_cartesian([rg_aussen, delta, mirrpoint-flankenpunkt_unten]),                             
                                        sphere_to_cartesian([rg_aussen, delta+schritt, flankenpunkt_oben]),
                                        sphere_to_cartesian([rg_innen, delta+schritt, flankenpunkt_oben+gamma]),
                                        sphere_to_cartesian([rg_innen, delta+schritt, mirrpoint-flankenpunkt_oben+gamma]),
                                        sphere_to_cartesian([rg_aussen, delta+schritt, mirrpoint-flankenpunkt_oben])                                   
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

/*  Bevel Herringbone Gear; uses the Module "bevel_gear"
    modul = Höhe des Zahnkopfes über dem Teilkreis
    tooth_number = Anzahl der Radzähne
    teilkegelwinkel, tooth_width
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel, Standardwert = 0° */
module bevel_herringbone_gear(modul, tooth_number, teilkegelwinkel, tooth_width, bore, pressure_angle = 20, helix_angle=0){

    // Dimensions-Berechnungen
    
    tooth_width = tooth_width / 2;
    
    d_aussen = modul * tooth_number;                                // Teilkegeldurchmesser auf der Kegelgrundfläche,
                                                                // entspricht der Sehne im Kugelschnitt
    r_aussen = d_aussen / 2;                                    // Teilkegelradius auf der Kegelgrundfläche 
    rg_aussen = r_aussen/sin(teilkegelwinkel);                  // Großkegelradius, entspricht der Länge der Kegelflanke;
    c = modul / 6;                                              // Kopfclearance
    df_aussen = d_aussen - (modul +c) * 2 * cos(teilkegelwinkel);
    rf_aussen = df_aussen / 2;
    delta_f = asin(rf_aussen/rg_aussen);
    height_f = rg_aussen*cos(delta_f);                           // Höhe des Kegels vom Fußkegel

    // Torsionswinkel gamma aus Schrägungswinkel
    gamma_g = 2*atan(tooth_width*tan(helix_angle)/(2*rg_aussen-tooth_width));
    gamma = 2*asin(rg_aussen/r_aussen*sin(gamma_g/2));
    
    echo("Teilkegeldurchmesser auf der Kegelgrundfläche = ", d_aussen);
    
    // Größen für Komplementär-Kegelstumpf
    height_k = (rg_aussen-tooth_width)/cos(teilkegelwinkel);      // Höhe des Komplementärkegels für richtige Zahnlänge
    rk = (rg_aussen-tooth_width)/sin(teilkegelwinkel);           // Fußradius des Komplementärkegels
    rfk = rk*height_k*tan(delta_f)/(rk+height_k*tan(delta_f));    // Kopfradius des Zylinders für 
                                                                // Komplementär-Kegelstumpf
    height_fk = rk*height_k/(height_k*tan(delta_f)+rk);            // height des Komplementär-Kegelstumpfs
    
    modul_innen = modul*(1-tooth_width/rg_aussen);

        union(){
        bevel_gear(modul, tooth_number, teilkegelwinkel, tooth_width, bore, pressure_angle, helix_angle);        // untere Hälfte
        translate([0,0,height_f-height_fk])
            rotate(a=-gamma,v=[0,0,1])
                bevel_gear(modul_innen, tooth_number, teilkegelwinkel, tooth_width, bore, pressure_angle, -helix_angle); // obere Hälfte
    }
}

/*  Spiral Bevel Gear; uses the Module "bevel_gear"
    modul = Höhe des Zahnkopfes über dem Teilkreis
    tooth_number = Anzahl der Radzähne
    height = Höhe des Zahnrads
    bore = Durchmesser der Mittelbohrung
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel, Standardwert = 0° */
module spiral_bevel_gear(modul, tooth_number, teilkegelwinkel, tooth_width, bore, pressure_angle = 20, helix_angle=30){

    schritte = 16;

    // Dimensions-Berechnungen
    
    b = tooth_width / schritte;  
    d_aussen = modul * tooth_number;                                // Teilkegeldurchmesser auf der Kegelgrundfläche,
                                                                // entspricht der Sehne im Kugelschnitt
    r_aussen = d_aussen / 2;                                    // Teilkegelradius auf der Kegelgrundfläche 
    rg_aussen = r_aussen/sin(teilkegelwinkel);                  // Großkegelradius, entspricht der Länge der Kegelflanke;
    rg_mitte = rg_aussen-tooth_width/2;

    echo("Teilkegeldurchmesser auf der Kegelgrundfläche = ", d_aussen);

    a=tan(helix_angle)/rg_mitte;
    
    union(){
    for(i=[0:1:schritte-1]){
        r = rg_aussen-i*b;
        helix_angle = a*r;
        modul_r = modul-b*i/rg_aussen;
        translate([0,0,b*cos(teilkegelwinkel)*i])
            
            rotate(a=-helix_angle*i,v=[0,0,1])
                bevel_gear(modul_r, tooth_number, teilkegelwinkel, b, bore, pressure_angle, helix_angle);   // obere Hälfte
        }
    }
}

/*  Bevel Gear Pair with any axis_angle; uses the Module "bevel_gear"
    modul = Höhe des Zahnkopfes über dem Teilkegel; Angabe für die Aussenseite des Kegels
    gear_teeth = Anzahl der Radzähne am Rad
    pinion_teeth = Anzahl der Radzähne am Ritzel
    axis_angle = Winkel zwischen den Achsen von Rad und Ritzel
    tooth_width = Breite der Zähne von der Außenseite in Richtung Kegelspitze
    gear_bore = Durchmesser der Mittelbohrung des Rads
    pinion_bore = Durchmesser der Mittelbohrungen des Ritzels
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel, Standardwert = 0°
    together_built = Komponenten zusammengebaut für Konstruktion oder auseinander zum 3D-Druck */
module bevel_gear_pair(modul, gear_teeth, pinion_teeth, axis_angle=90, tooth_width, gear_bore, pinion_bore, pressure_angle=20, helix_angle=0, together_built=true){
 
    // Dimensions-Berechnungen
    r_gear = modul*gear_teeth/2;                           // Teilkegelradius des Rads
    delta_gear = atan(sin(axis_angle)/(pinion_teeth/gear_teeth+cos(axis_angle)));   // Kegelwinkel des Rads
    delta_pinion = atan(sin(axis_angle)/(gear_teeth/pinion_teeth+cos(axis_angle)));// Kegelwingel des Ritzels
    rg = r_gear/sin(delta_gear);                              // Radius der Großkugel
    c = modul / 6;                                          // Kopfclearance
    df_pinion = pi*rg*delta_pinion/90 - 2 * (modul + c);    // Fußkegeldurchmesser auf der Großkugel 
    rf_pinion = df_pinion / 2;                              // Fußkegelradius auf der Großkugel
    delta_f_pinion = rf_pinion/(pi*rg) * 180;               // Kopfkegelwinkel
    rkf_pinion = rg*sin(delta_f_pinion);                    // Radius des Kegelfußes
    height_f_pinion = rg*cos(delta_f_pinion);                // Höhe des Kegels vom Fußkegel
    
    echo("Cone Angle Gear = ", delta_gear);
    echo("Cone Angle Pinion = ", delta_pinion);
 
    df_gear = pi*rg*delta_gear/90 - 2 * (modul + c);          // Fußkegeldurchmesser auf der Großkugel 
    rf_gear = df_gear / 2;                                    // Fußkegelradius auf der Großkugel
    delta_f_gear = rf_gear/(pi*rg) * 180;                     // Kopfkegelwinkel
    rkf_gear = rg*sin(delta_f_gear);                          // Radius des Kegelfußes
    height_f_gear = rg*cos(delta_f_gear);                      // Höhe des Kegels vom Fußkegel

    echo("Gear Height = ", height_f_gear);
    echo("Pinion Height = ", height_f_pinion);
    
    drehen = istgerade(pinion_teeth);
    
    // Zeichnung
    // Rad
    rotate([0,0,180*(1-clearance)/gear_teeth*drehen])
        bevel_gear(modul, gear_teeth, delta_gear, tooth_width, gear_bore, pressure_angle, helix_angle);
    
    // Ritzel
    if (together_built)
        translate([-height_f_pinion*cos(90-axis_angle),0,height_f_gear-height_f_pinion*sin(90-axis_angle)])
            rotate([0,axis_angle,0])
                bevel_gear(modul, pinion_teeth, delta_pinion, tooth_width, pinion_bore, pressure_angle, -helix_angle);
    else
        translate([rkf_pinion*2+modul+rkf_gear,0,0])
            bevel_gear(modul, pinion_teeth, delta_pinion, tooth_width, pinion_bore, pressure_angle, -helix_angle);
 }

/*  Herringbone Bevel Gear Pair with arbitrary axis_angle; uses the Module "bevel_herringbone_gear"
    modul = Höhe des Zahnkopfes über dem Teilkegel; Angabe für die Aussenseite des Kegels
    gear_teeth = Anzahl der Radzähne am Rad
    pinion_teeth = Anzahl der Radzähne am Ritzel
    axis_angle = Winkel zwischen den Achsen von Rad und Ritzel
    tooth_width = Breite der Zähne von der Außenseite in Richtung Kegelspitze
    gear_bore = Durchmesser der Mittelbohrung des Rads
    pinion_bore = Durchmesser der Mittelbohrungen des Ritzels
    pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    helix_angle = Schrägungswinkel, Standardwert = 0°
    together_built = Komponenten zusammengebaut für Konstruktion oder auseinander zum 3D-Druck */
module bevel_herringbone_gear_pair(modul, gear_teeth, pinion_teeth, axis_angle=90, tooth_width, gear_bore, pinion_bore, pressure_angle = 20, helix_angle=10, together_built=true){
 
    r_gear = modul*gear_teeth/2;                           // Teilkegelradius des Rads
    delta_gear = atan(sin(axis_angle)/(pinion_teeth/gear_teeth+cos(axis_angle)));   // Kegelwinkel des Rads
    delta_pinion = atan(sin(axis_angle)/(gear_teeth/pinion_teeth+cos(axis_angle)));// Kegelwingel des Ritzels
    rg = r_gear/sin(delta_gear);                              // Radius der Großkugel
    c = modul / 6;                                          // Kopfclearance
    df_pinion = pi*rg*delta_pinion/90 - 2 * (modul + c);    // Fußkegeldurchmesser auf der Großkugel 
    rf_pinion = df_pinion / 2;                              // Fußkegelradius auf der Großkugel
    delta_f_pinion = rf_pinion/(pi*rg) * 180;               // Kopfkegelwinkel
    rkf_pinion = rg*sin(delta_f_pinion);                    // Radius des Kegelfußes
    height_f_pinion = rg*cos(delta_f_pinion);                // Höhe des Kegels vom Fußkegel
    
    echo("Cone Angle Gear = ", delta_gear);
    echo("Cone Angle Pinion = ", delta_pinion);
 
    df_gear = pi*rg*delta_gear/90 - 2 * (modul + c);          // Fußkegeldurchmesser auf der Großkugel 
    rf_gear = df_gear / 2;                                    // Fußkegelradius auf der Großkugel
    delta_f_gear = rf_gear/(pi*rg) * 180;                     // Kopfkegelwinkel
    rkf_gear = rg*sin(delta_f_gear);                          // Radius des Kegelfußes
    height_f_gear = rg*cos(delta_f_gear);                      // Höhe des Kegels vom Fußkegel

    echo("Gear Height = ", height_f_gear);
    echo("Pinion Height = ", height_f_pinion);
    
    drehen = istgerade(pinion_teeth);
    
    // Rad
    rotate([0,0,180*(1-clearance)/gear_teeth*drehen])
        bevel_herringbone_gear(modul, gear_teeth, delta_gear, tooth_width, gear_bore, pressure_angle, helix_angle);
    
    // Ritzel
    if (together_built)
        translate([-height_f_pinion*cos(90-axis_angle),0,height_f_gear-height_f_pinion*sin(90-axis_angle)])
            rotate([0,axis_angle,0])
                bevel_herringbone_gear(modul, pinion_teeth, delta_pinion, tooth_width, pinion_bore, pressure_angle, -helix_angle);
    else
        translate([rkf_pinion*2+modul+rkf_gear,0,0])
            bevel_herringbone_gear(modul, pinion_teeth, delta_pinion, tooth_width, pinion_bore, pressure_angle, -helix_angle);

}

/*
Archimedean screw.
modul = Höhe des Schneckenkopfes über dem Teilzylinder
thread_starts = Anzahl der Gänge (Zähne) der Schnecke
length = Länge der Schnecke
bore = Durchmesser der Mittelbohrung
pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
lead_angle = lead_angle der Schnecke, entspricht 90° minus Schrägungswinkel. Positiver lead_angle = rechtsdrehend.
together_built = Komponenten zusammengebaut für Konstruktion oder auseinander zum 3D-Druck */
module worm(modul, thread_starts, length, bore, pressure_angle=20, lead_angle, together_built=true){

    // Dimensions-Berechnungen
    c = modul / 6;                                              // Kopfclearance
    r = modul*thread_starts/(2*sin(lead_angle));                // Teilzylinder-Radius
    rf = r - modul - c;                                         // Fußzylinder-Radius
    a = modul*thread_starts/(90*tan(pressure_angle));               // Spiralparameter
    tau_max = 180/thread_starts*tan(pressure_angle);                // Winkel von Fuß zu Kopf in der Normalen
    gamma = -rad*length/((rf+modul+c)*tan(lead_angle));    // Torsionswinkel für Extrusion
    
    schritt = tau_max/16;
    
    // Zeichnung: extrudiere mit Verwindung eine Flaeche, die von zwei archimedischen Spiralen eingeschlossen wird
    if (together_built) {
        rotate([0,0,tau_max]){
            linear_extrude(height = length, center = false, convexity = 10, twist = gamma){
                difference(){
                    union(){
                        for(i=[0:1:thread_starts-1]){
                            polygon(
                                concat(                         
                                    [[0,0]],
                                    
                                    // ansteigende Zahnflanke
                                    [for (tau = [0:schritt:tau_max])
                                        polar_to_cartesian([spirale(a, rf, tau), tau+i*(360/thread_starts)])],
                                        
                                    // Zahnkopf
                                    [for (tau = [tau_max:schritt:180/thread_starts])
                                        polar_to_cartesian([spirale(a, rf, tau_max), tau+i*(360/thread_starts)])],
                                    
                                    // absteigende Zahnflanke
                                    [for (tau = [180/thread_starts:schritt:(180/thread_starts+tau_max)])
                                        polar_to_cartesian([spirale(a, rf, 180/thread_starts+tau_max-tau), tau+i*(360/thread_starts)])]
                                )
                            );
                        }
                        circle(rf);
                    }
                    circle(bore/2); // Mittelbohrung
                }
            }
        }
    }
    else {
        difference(){
            union(){
                translate([1,r*1.5,0]){
                    rotate([90,0,90])
                        worm(modul, thread_starts, length, bore, pressure_angle, lead_angle, together_built=true);
                }
                translate([length+1,-r*1.5,0]){
                    rotate([90,0,-90])
                        worm(modul, thread_starts, length, bore, pressure_angle, lead_angle, together_built=true);
                    }
                }
            translate([length/2+1,0,-(r+modul+1)/2]){
                    cube([length+2,3*r+2*(r+modul+1),r+modul+1], center = true);
                }
        }
    }
}

/*
Calculates a worm wheel set. The worm wheel is an ordinary spur gear without globoidgeometry.
modul = Height of the screw head above the partial cylinder or the tooth head above the pitch circle
tooth_number = Number of wheel teeth
thread_starts = Number of gears (teeth) of the screw
width = tooth_width
length = Länge der Schnecke
worm_bore = Durchmesser der Mittelbohrung der Schnecke
gear_bore = Durchmesser der Mittelbohrung des Stirnrads
pressure_angle = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
lead_angle = Pitch angle of the worm corresponds to 90 ° bevel angle. Positive slope angle = clockwise.
optimized = Holes for material / weight savings
together_built =  Components assembled for construction or apart for 3D printing */
module worm_gear(modul, tooth_number, thread_starts, width, length, worm_bore, gear_bore, pressure_angle=20, lead_angle, optimized=true, together_built=true, show_spur=1, show_worm=1){
    
    c = modul / 6;                                              // Kopfclearance
    r_worm = modul*thread_starts/(2*sin(lead_angle));       // Teilzylinder-Radius Schnecke
    r_gear = modul*tooth_number/2;                                   // Teilkegelradius Stirnrad
    rf_worm = r_worm - modul - c;                       // Fußzylinder-Radius
    gamma = -90*width*sin(lead_angle)/(pi*r_gear);         // Rotationswinkel Stirnrad
    zahnabstand = modul*pi/cos(lead_angle);                // Zahnabstand im Transversalschnitt
    x = istgerade(thread_starts)? 0.5 : 1;

    if (together_built) {
        if(show_worm)
        translate([r_worm,(ceil(length/(2*zahnabstand))-x)*zahnabstand,0])
            rotate([90,180/thread_starts,0])
                worm(modul, thread_starts, length, worm_bore, pressure_angle, lead_angle, together_built);

        if(show_spur)
        translate([-r_gear,0,-width/2])
            rotate([0,0,gamma])
                spur_gear (modul, tooth_number, width, gear_bore, pressure_angle, -lead_angle, optimized);
    }
    else {  
        if(show_worm)
        worm(modul, thread_starts, length, worm_bore, pressure_angle, lead_angle, together_built);

        if(show_spur)
        translate([-2*r_gear,0,0])
            spur_gear (modul, tooth_number, width, gear_bore, pressure_angle, -lead_angle, optimized);
    }
}

// rack(modul=1, length=30, height=5, width=5, pressure_angle=20, helix_angle=20);

//spur_gear (modul=1, tooth_number=30, width=5, bore=4, pressure_angle=20, helix_angle=20, optimized=true);

//herringbone_gear (modul=1, tooth_number=30, width=5, bore=4, pressure_angle=20, helix_angle=30, optimized=true);

//rack_and_pinion (modul=1, rack_length=50, gear_teeth=30, rack_height=4, gear_bore=4, width=5, pressure_angle=20, helix_angle=0, together_built=true, optimized=true);

//ring_gear (modul=1, tooth_number=30, width=5, rim_width=3, pressure_angle=20, helix_angle=20);

// herringbone_ring_gear (modul=1, tooth_number=30, width=5, rim_width=3, pressure_angle=20, helix_angle=30);

//planetary_gear(modul=1, sun_teeth=16, planet_teeth=9, number_planets=5, width=5, rim_width=3, bore=4, pressure_angle=20, helix_angle=30, together_built=true, optimized=true);

//bevel_gear(modul=1, tooth_number=30,  teilkegelwinkel=45, tooth_width=5, bore=4, pressure_angle=20, helix_angle=20);

// bevel_herringbone_gear(modul=1, tooth_number=30, teilkegelwinkel=45, tooth_width=5, bore=4, pressure_angle=20, helix_angle=30);

// bevel_gear_pair(modul=1, gear_teeth=30, pinion_teeth=11, axis_angle=100, tooth_width=5, bore=4, pressure_angle = 20, helix_angle=20, together_built=true);

// bevel_herringbone_gear_pair(modul=1, gear_teeth=30, pinion_teeth=11, axis_angle=100, tooth_width=5, bore=4, pressure_angle = 20, helix_angle=30, together_built=true);

// worm(modul=1, thread_starts=2, length=15, bore=4, pressure_angle=20, lead_angle=10, together_built=true);

worm_gear(modul=1, tooth_number=30, thread_starts=2, width=8, length=20, worm_bore=4, gear_bore=4, pressure_angle=20, lead_angle=10, optimized=1, together_built=1, show_spur=1, show_worm=1);
