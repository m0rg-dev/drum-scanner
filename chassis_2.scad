include <common.scad>

module chassis_2() {
    difference() {
        union() {
            translate([-27/2, drum_len_mm - 30, 0]) cube([27, 50, 15]);
            translate([-27/2, drum_len_mm + 2, 0]) cube([27, 50 - 30 - 2, 50]);
        }
        translate([0, drum_len_mm - 31, 15/2]) rotate([-90, 0, 0]) cylinder(d = 5.5, h = 60);
        translate([0, drum_len_mm, 15/2]) rotate([-90, 0, 0]) cylinder(d = 10, h = 60);
        translate([10, drum_len_mm - 30 + 10, -1]) cylinder(d = 3.2, h = 20);
        translate([-10, drum_len_mm - 30 + 10, -1]) cylinder(d = 3.2, h = 20);
        translate([10, drum_len_mm - 30 + 25, -1]) cylinder(d = 3.2, h = 20);
        translate([-10, drum_len_mm - 30 + 25, -1]) cylinder(d = 3.2, h = 20);
        
        translate([10, drum_len_mm, 40]) rotate([-90, 0, 0]) cylinder(d = 3.2, h = 40);
        translate([-10, drum_len_mm, 40]) rotate([-90, 0, 0]) cylinder(d = 3.2, h = 40);
    }
}

if(!disable_individual_models) {
    chassis_2();
} 
