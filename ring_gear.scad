include <common.scad>

module ring_gear() {
    difference() {
        translate([0, 0, 5]) spur_gear(n = ring_gear_n, m = 1, z = 10, helix_angle = herringbone());
        translate([0, 0, -1]) cylinder(d = drum_od_mm - ring_gear_radius_offset_mm * 2, h = 12);
    }
}

if(!disable_individual_models) {
    ring_gear();
}