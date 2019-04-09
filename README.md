AletheianAlex NOTE: this is a fork of https://github.com/chrisspen/gears where I made a humble attempt to translate the comments and functions to English. Below is Chrisspen's README:

OpenSCAD gear generator
=======================

This is a fork of [this OpenSCAD gear generator](https://www.thingiverse.com/thing:1604369), translated into English.

OpenSCAD Library for Gear Racks, Involute and Worm Gears

A library for the parametric creation of gear racks, spur-, ring-, bevel- and worm gears, as well as of assemblies.

Parametric Gear Rack
--------------------

Creates a gear rack.

This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 20° helix angle, a pressure angle of 20° becomes a pressure angle of 21.17° in the transverse section.

<h5>Format:</h5>
zahnstange(modul, laenge, hoehe, breite, eingriffswinkel=20, schraegungswinkel=0)  <br>
Translated:  <br>
rack (module, length, height, width, pressure_angle = 20, helix_angle = 0)

<h5>Parameters:</h5>  
modul = height of the tooth above the pitch line  <br>
laenge = length of the rack  <br>
hoehe = height from bottom to the pitch line  <br>
breite = face width  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867. Should not be greater than 45°.  <br>
schraegungswinkel = bevel angle perpendicular to the rack's length; 0° = straight teeth  


<h4>Parametric Involute Spur Gear</h4>

Creates an involute spur gear without profile displacement following DIN 867 / DIN 58400. Two gears will mesh if their modules are the same and their helix angles opposite. The centre distance of two meshing gears A and B with module m and tooth numbers z<sub>a</sub> and z<sub>b</sub> is 
<sup>m</sub></sup>/<sub>2</sub>·(z<sub>a</sub> + z<sub>b</sub>)

Helical gears run more smoothly than gears with straight teeth. However, they also create axial loads which the bearings must be designed to contain. Recommendations for the helix angle depending on the module can be found in DIN 3978.

This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 20° helix angle, a pressure angle of 20° becomes a pressure angle of 21.17° in the transverse section.

<h5>Format:</h5>
stirnrad (modul, zahnzahl, breite, bohrung, eingriffswinkel=20, schraegungswinkel=0, optimiert=true)  <br>
Translated:  <br>
spur_gear (module, tooth_number, width, bore, pressure_angle = 20, helix_angle = 0, optimized = true)

<h5>Parameters:</h5>
modul = gear module = height of the tooth above the pitch circle = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl = number of teeth  <br>
breite = face width  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle to the rotation axis; 0° = straight teeth  <br>
optimiert = if true, create holes for material/weight reduction resp. surface increase, if geometry allows  


<h4>Parametric Herringbone Involute Spur Gear</h4>

Creates a herringbone spur gear without profile displacement. Two gears will mesh if their modules are the same and their helix angles opposite. The centre distance of two meshing gears with module m and tooth numbers z<sub>a</sub> and z<sub>b</sub> is 
<sup>m</sub></sup>/<sub>2</sub>·(z<sub>a</sub> + z<sub>b</sub>)

Herringbone gears run more smoothly than gears with straight teeth. They also do not create torque on the axis like helical gears do.

A helix angle, if used, should be set between between 30° and 45°. Recommendations for the helix angle depending on the module can be found in DIN 3978.

This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 30° helix angle, a pressure angle of 20° becomes a pressure angle of 22.80 in the transverse section.

<h5>Format:</h5>
pfeilrad (modul, zahnzahl, breite, bohrung, eingriffswinkel=20, schraegungswinkel=0, optimiert=true)  <br>
Translation:  <br>
herringbone_gear (module, tooth_number, width, bore, pressure_angle = 20, helix_angle = 0, optimized = true)

<h5>Parameters:</h5>
modul = gear module = height of the tooth above the pitch circle = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl = number of teeth  <br>
breite = face width  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle to the rotation axis; 0° = straight teeth  <br>
optimiert = if true, create holes for material/weight reduction resp. surface increase, if geometry allows  


<h4>Parametric Gear Rack and Pinion</h4>

Creates a gear rack and pinion.

Helical gears / bevelled racks run more smoothly than gears with straight teeth. However, they also create axial loads which the bearings must be designed to contain. Recommendations for the helix angle depending on the module can be found in DIN 3978.

With a given module m and z<sub>p</sub> teeth on the pinion, the distance between the pinion's axis and the rack's pitch line is
<sup>m</sub></sup>/<sub>2</sub>·z<sub>p</sub>

This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 20° helix angle, a pressure angle of 20° becomes a pressure angle of 21.17° in the transverse section.

<h5>Format:</h5>
zahnstange(modul, laenge, hoehe, breite, eingriffswinkel=20, schraegungswinkel=0)  <br>
Translation:  <br>
rack_and_pinion (module, rack_length, pinion_teeth, rack_height, pinion_bore, width, pressure_angle = 20, helix_angle = 0, together_built = true, optimized = true)

<h5>Parameters:</h5>
modul = gear module = height of the tooth above the pitch line/pitch circle = 25.4 / diametrical pitch = circular pitch / π  <br>
laenge_stange = length of the rack  <br>
zahnzahl_ritzel = number of teeth on the pinion  <br>
hoehe_stange = height from bottom to the pitch line  <br>
bohrung_ritzel = central bore diameter of the pinion  <br>
breite = face width  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = bevel angle perpendicular to the rack's length resp. helix angle to the rotation axis on the pinion; 0° = straight teeth  <br>
zusammen_gebaut = assembled (true) or disassembled for printing (false)  


+++

<h4>Parametric Involute Ring Gear</h4>

Creates a herringbone ring gear without profile displacement. Helical gears run more smoothly than gears with straight teeth. However, they also create axial loads which the bearings must be designed to contain. Recommendations for the helix angle depending on the module can be found in DIN 3978.

This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 20° helix angle, a pressure angle of 20° becomes a pressure angle of 21.17° in the transverse section.

<h5>Format:</h5>
hohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel=20, schraegungswinkel=0)  <br>
Translation:  <br>
ring_gear (module, tooth_number, width, border_width, pressure_angle = 20, helix_angle = 0)

<h5>Parameters:</h5>
modul = gear module = height of the tooth above the pitch circle = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl = number of teeth  <br>
breite = face width  <br>
randbreite = width of the rim around the ring gear, measured from the root circle  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle to the rotation axis; 0° = straight teeth


<h4>Parametric Herringbone Involute Ring Gear</h4>

Creates a herringbone ring gear without profile displacement. A ring and spur gear mesh if they have the same module and opposite helix angels. Herringbone gears run more smoothly than gear with straight teeth. They also do not create axial load like helical gears do.

A helix angle, if used, should be set between between 30° and 45°. Recommendations for the helix angle depending on the module can be found in DIN 3978. This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 30° helix angle, a pressure angle of 20° becomes a pressure angle of 22.80° in the transverse section.

<h5>Format:</h5>
pfeilhohlrad(modul, zahnzahl, breite, randbreite, eingriffswinkel=20, schraegungswinkel=0)  <br>
Translation:  <br>
herringbone_ring_gear (modul, tooth_number, width, borderwidth, pressure_angle = 20, helix_angle = 0)

<h5>Parameters:</h5>
modul = gear module = height of the tooth above the pitch circle = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl = number of teeth  <br>
breite = face width  <br>
randbreite = width of the rim around the ring gear, measured from the root circle  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle to the rotation axis; 0° = straight teeth

+++

<h3>Parametric Planetary Gear using Involute Tooth Geometry and Herringbone Shape</h3>

This script calculates both the ring gear as well as, if required, the number and geometry of the planetary gears from the number of teeth on the sun and planets. For a module of <i>m</i>, <i>z<sub>s</sub></i> teeth for the sun and <i>z<sub>p</sub></i> teeth for the planets, the centre distance will be
<sup>m</sub></sup>/<sub>2</sub>·(z<sub>s</sub> + z<sub>p</sub>)

If the number of planets is set to zero (anzahl_planeten = 0) then the module will try and calculate them.

For a module of  <i>m</i>, <i>z<sub>s</sub></i> teeth for the sun, <i>z<sub>p</sub></i> teeth for the planets and a rim width of <i>b<sub>r</sub></i>, the outer diameter is m·(z<sub>s</sub>+2z<sub>p</sub>+2.333)+2b<sub>r</sub>

The helix angle should be between between 30° and 45°. Recommendations for the helix angle depending on the module can be found in DIN 3978. This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 30° helix angle, a pressure angle 20° becomes a pressure angle of 22.80° in the transverse section.

If no number of gears is given (anzahl_planeten = 0), then the script will attempt to calculate the least number of planet gears.

To avoid the gears sticking in a 3D print, particularly sticking of the planet gears to the ring gear, the gears can be printed in disassembled layout (zusammen gebaut = false). In that case, please note that herringbone teeth complicate the re-assembly. Experience shows that reassembly is still possible at 30°; however in case of reassembly problems, a lesser helix angle should be selected. Of course, one could always choose straight teeth (Schraegungswinkel = 0).

The gears can also be kept from sticking by a sufficiently large clearance ("Spiel"); a sufficient clearance also avoids meshing problems. Clearance can be left smaller if the 3D printer offers good resolution, however experience shows that it should not be less than 5%.

<h5>Format:</h5>
planetengetriebe(modul, zahnzahl_sonne, zahnzahl_planet, breite, randbreite, bohrung, eingriffswinkel=20, schraegungswinkel=0, zusammen_gebaut=true, optimiert=true)  <br>
Translation:  <br>
planetary_gear (module, sun_teeth, planet_teeth, number_planets, width, ring_width, bore, pressure_angle = 20, helix_angle = 0, together_built = true, optimized = true)

<h5>Parameters:</h5>
spiel = clearance between teeth as a fraction of their width (0 = no clearance)  <br>
modul = gear module = height of the tooth above the pitch circle = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl_sonne = number of teeth on the sun gear  <br>
zahnzahl_planet = number of teeth per planet gear  <br>
anzahl_planeten = number of planet gears; if set to zero, the script will attempt to calculate the least number of planet gears  <br>
breite = face width  <br>
randbreite = width of the rim around the ring gear, measured from the root circle  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle to the rotation axis; 0° = straight teeth  <br>
zusammen_gebaut = components assembled for construction (true) or disassembled (false) for 3D printing  <br>
optimiert = if true, create holes for material/weight reduction resp. surface increase, if geometry allows

+++

<h4>Parametric Herringbone Bevel Gear with Spherical Involute Geometry</h4>

This script creates a herringbone bevel gear with spherical involute teeth geometry. Two gears will mesh if their modules are the same and their helix angles opposite. Herringbone gears run more smoothly than gear with straight teeth. They also do not create axial load like helical gears do. Recommendations for the helix angle depending on the module can be found in DIN 3978.

This script adjusts the pressure angle in the transverse section to the helix angle: e.g. with a 30° helix angle, a pressure angle of 20° becomes a pressure angle of 22.80° in the transverse section.

<h5>Format:</h5>
pfeilkegelrad(modul, zahnzahl, teilkegelwinkel, zahnbreite, bohrung, eingriffswinkel=20, schraegungswinkel=0)  <br>
Translation:<br>
bevel_herringbone_gear (module, tooth_number, ref_cone_angle_half, tooth_width, bore, pressure_angle = 20, helix_angle = 0)

<h5>Parameters:</h5>
modul = gear module = height of the gear teeth above the pitch cone = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl = number of teeth  <br>
teilkegelwinkel = reference cone (half-)angle  <br>
zahnbreite = width of teeth from the rim in direction of the reference cone tip  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle between the teeth and the reference cone envelope line, 0° = straight teeth

+++

<h4>Parametric Pair of Bevel Gears</h4>

This script calculates both the gear and the pinion of a bevel gear pair, using the gears' module and their numbers of teeth. The preset angle of 90° between the axes of both gears can be varied. It is possible to calculate the pair both assembled for design as well as disassembled for printing.

<h5>Format:</h5>
kegelradpaar(modul, zahnzahl_rad, zahnzahl_ritzel, achsenwinkel=90, zahnbreite, bohrung, eingriffswinkel = 20, schraegungswinkel=0, zusammen_gebaut=true)  <br>
Translation:  <br>
bevel_gear_pair (module, gear_teeth, pinion_teeth, axis_angle = 90, tooth_width, bore, pressure_angle = 20, helix_angle = 0, together_built = true)

<h5>Parameters:</h5>
modul = gear module = height of the gear teeth above the pitch cone = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl_rad = number of teeth on the gear  <br>
zahnzahl_ritzel = number of teeth on the pinion <br> 
achsenwinkel = angle between the axes of pinion and gear, standard value = 90°  <br>
zahnbreite = width of the teeth from the rim in direction of the cone tip  <br>
bohrung_rad = central bore diameter of the gear  <br>
bohrung_ritzel = central bore diameter of the pinion  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle between the teeth and the reference cone envelope line, 0° = straight teeth  <br>
zusammen_gebaut = assembled (true) oder disassembled for printing (false)


+++

<h4>Parametric Pair of Herringbone Bevel Gears</h4>

This script calculates both the gear and the pinion of a herringbone bevel gear pair, using the gears' module and their numbers of teeth. The preset angle of 90° between the axes of both gears can be varied. It is possible to calculate the pair both assembled for design as well as disassembled for printing.

<h5>Format:</h5>
pfeilkegelradpaar(modul, zahnzahl_rad, zahnzsahl_ritzel, achsenwinkel=90, zahnbreite, bohrung, eingriffswinkel = 20, schraegungswinkel=0, zusammen_gebaut=true)  <br>
Translation:  <br>
bevel_herringbone_gear_pair (module, gear_teeth, pinion_teeth, axis_angle = 90, tooth_width, bore, pressure_angle = 20, helix_angle = 0, together_built = true)

<h5>Parameters:</h5>
modul = gear module = height of the gear teeth above the pitch cone = 25.4 / diametrical pitch = circular pitch / π  <br>
zahnzahl_rad = number of teeth on the gear  <br>
zahnzahl_ritzel = number of teeth on the pinion  <br>
achsenwinkel = angle between the axes of pinion and gear, standard value = 90°  <br>
zahnbreite = width of the teeth from the rim in direction of the cone tip  <br>
bohrung_rad = central bore diameter of the gear  <br>
bohrung_ritzel = central bore diameter of the pinion  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
schraegungswinkel = helix angle between the teeth and the reference cone envelope line, 0° = straight teeth  <br>
zusammen_gebaut = assembled (true) or disassembled for printing (false)

+++

<h4>Parametric Worm</h4>

Creates a cylidrical worm (archimedean spiral) following DIN 3975.

The worm's pitch circle r can be calculated out of its module m, number of threads z and lead angle γ:

r = m·z·<sup>1</sup>/<sub>2sinγ</sub> 

<h5>Format:</h5>
schnecke(modul, gangzahl, laenge, bohrung, eingriffswinkel=20, steigungswinkel=10, zusammen_gebaut=true)  <br>
Translation:  <br>
worm (module, thread_starts, length, bore, pressure_angle = 20, helix_angle = 10, together_built = true)

<h5>Parameters:</h5>
modul = height of the thread above the pitch circle  <br>
gangzahl = number of threads  <br>
laenge = length of the worm  <br>
bohrung = central bore diameter  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867  <br>
steigungswinkel = lead angle of worm. Positive lead angle = clockwise thread rotation  <br>
zusammen_gebaut = assembled (true) or disassembled for printing (false)


+++

<h4> Worm Gear Set  (Worm and Pinion)</h4>

Creates a set of one worm gear and a pinion. The pinion is a normal spur gear without globoid geometry.

<h5>Format:</h5>
module schneckenradsatz(modul, zahnzahl, gangzahl, breite, laenge, bohrung_schnecke, bohrung_rad, eingriffswinkel=20, steigungswinkel, optimiert=true, zusammen_gebaut=true)  <br>
Translation:  <br>
worm_gear (module, tooth_number, thread_starts, width, length, bore_screw, bore_rad, pressure_angle = 20, helix_angle = 0, optimized = true, together_built = true)

<h5>Parameter:</h5>

modul = gear module = and height of the gear teeth above th pitch circle / of the thread above the pitch circle  <br>
zahnzahl = number of teeth on the pinion  <br>
gangzahl = number of threads  <br>
breite = face width on the pinion  <br>
laenge = length of the worm  <br>
bohrung_schnecke = central bore diameter of the worm  <br>
bohrung_rad = central bore diameter of the pinion  <br>
eingriffswinkel = pressure angle, standard value = 20° according to DIN 867. Shouldn't be greater than 45°  <br>
steigungswinkel = lead angle of worm. Positive lead angle = clockwise thread rotation  <br>
optimiert = if true, create holes for material/weight reduction resp. surface increase, if geometry allows  <br>
zusammen_gebaut =  assembled (true) or disassembled for printing (false)
