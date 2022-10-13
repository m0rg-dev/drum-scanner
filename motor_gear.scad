include <common.scad>

module motor_gear() {
    difference() {
        union() {
            translate([0, 0, 5]) spur_gear(n = motor_gear_n, m = 1, z = 10, helix_angle = herringbone(helix=-30));
            translate([0, 0, -7]) cylinder(d = 10, h = 7);
        }
        translate([0, 0, -15]) cylinder(d = 5.2, h = 30);
        translate([0, 0, -3.5]) rotate([90, 0, 0]) cylinder(d = 2.9, h = 10);
    }
}

if(!disable_individual_models) {
    motor_gear();
}
