include <common.scad>

include <MCAD/bearing.scad>

//drum();

module bearings() {
    translate([0, 0, 6]) {
        translate([(drum_id_mm - 22) / 2, 0, 0]) bearing(model = 608);
        rotate([0, 0, 120]) translate([(drum_id_mm - 22) / 2, 0, 0]) bearing(model = 608);
        rotate([0, 0, -120]) translate([(drum_id_mm - 22) / 2, 0, 0]) bearing(model = 608);
    }
}

module bearing_post() {
    cylinder(d = 9, h = 1);
    translate([0, 0, 1]) cylinder(d = bearing_post_diameter, h = 8);
}

module bearing_frame(include_bearings = false) {
    difference() {
        cylinder(d = drum_id_mm - 10, h = 5);
        translate([0, 0, -1]) cylinder(d = drum_id_mm - 32, h = 7);
        translate([(drum_od_mm - 30)/2, 10, -1]) cylinder(d = 2.8, h = 10);
        translate([(drum_od_mm - 30)/2, -10, -1]) cylinder(d = 2.8, h = 10);
    }

    translate([(drum_id_mm - 22) / 2, 0, 5]) bearing_post();
    rotate([0, 0, 120]) translate([(drum_id_mm - 22) / 2, 0, 5]) bearing_post();
    rotate([0, 0, -120]) translate([(drum_id_mm - 22) / 2, 0, 5]) bearing_post();
    
    if(include_bearings) {
        bearings();
    }
}

if(!disable_individual_models) {
    bearing_frame();
}