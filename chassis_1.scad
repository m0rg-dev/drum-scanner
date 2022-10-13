include <common.scad>

module chassis_1() {
    difference() {
        union() {
            translate([-27/2, -20, 0]) cube([27, drum_len_mm - 10, 15]);
            translate([-27/2, -20, 0]) cube([27, 50 - 30 - 2, 50]);
            hull() {
                translate([-27/2, -13, 0]) cube([27, 8, 50]);
                translate([42/2, 3, drum_od_mm/2 + 25 + 42/2]) rotate([0, motor_angle, 180]) {
                    translate([drum_motor_center_distance, 8, 0]) rotate([-90, -motor_angle, 0]) {
                        cube([44, 42, 8]);
                    }
                }
            }
        }
        translate([10, -40, 40]) rotate([-90, 0, 0]) cylinder(d = 3.2, h = 40);
        translate([-10, -40, 40]) rotate([-90, 0, 0]) cylinder(d = 3.2, h = 40);
        translate([0, -21, 15/2]) rotate([-90, 0, 0]) cylinder(d = 5.5, h = drum_len_mm);


        translate([10, 10, -1]) cylinder(d = 3.2, h = 20);
        translate([-10, 10, -1]) cylinder(d = 3.2, h = 20);
        translate([10, 25, -1]) cylinder(d = 3.2, h = 20);
        translate([-10, 25, -1]) cylinder(d = 3.2, h = 20);

        hull() {
            translate([0, drum_len_mm - 45, 15/2 - 0.5]) rotate([-90, 90, 0]) cylinder(d = 9.4, h = 5, $fn = 6);
            translate([0, drum_len_mm - 45, 15/2 + 30]) rotate([-90, 90, 0]) cylinder(d = 9.4, h = 5, $fn = 6);

        }
        
        translate([0, 4, drum_od_mm/2 + 25]) rotate([0, motor_angle, 180]) {
            translate([drum_motor_center_distance, 8, 0]) rotate([-90, -motor_angle, 0]) {
                hull() {
                    translate([2, 0, 0]) cylinder(d=25, h=10);
                    translate([-2, 0, 0]) cylinder(d=25, h=10);
                }
                hull() {
                    translate([31/2 + 2, 31/2, 0]) cylinder(d = 3.2, h = 10);
                    translate([31/2 - 2, 31/2, 0]) cylinder(d = 3.2, h = 10);
                }
                
                hull() {
                    translate([-31/2 + 2, 31/2, 0]) cylinder(d = 3.2, h = 10);
                    translate([-31/2 - 2, 31/2, 0]) cylinder(d = 3.2, h = 10);
                }
                
                hull() {
                    translate([31/2 + 2, -31/2, 0]) cylinder(d = 3.2, h = 10);
                    translate([31/2 - 2, -31/2, 0]) cylinder(d = 3.2, h = 10);
                }
                
                hull() {
                    translate([-31/2 + 2, -31/2, 0]) cylinder(d = 3.2, h = 10);
                    translate([-31/2 - 2, -31/2, 0]) cylinder(d = 3.2, h = 10);
                }
            }
        }
        
        // lead screw bracket
        translate([20, -10, 15]) rotate([0, -90, 0]) cylinder(d=2.8, h = 30);
        translate([20, -10, 25]) rotate([0, -90, 0]) cylinder(d=2.8, h = 30);
    }
}

if(!disable_individual_models) {
    chassis_1();
}

