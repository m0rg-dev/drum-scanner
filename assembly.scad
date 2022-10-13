include <common.scad>

include <ring_gear.scad>
include <motor_gear.scad>
include <bearing_frame.scad>
include <chassis_1.scad>
include <chassis_2.scad>

include <MCAD/stepper.scad>

disable_individual_models = 1;

module drum_complete() {
    color("#77ffff") ring_gear();
    //drum();
}


module motor_complete() {
    rotate([0, motor_angle, 0]) {
        translate([drum_motor_center_distance, 11, 0]) rotate([-90, -motor_angle, 0]) motor(Nema17, NemaShort);
        translate([drum_motor_center_distance, 0, 0]) rotate([90, 0, 0]) color("#77ffff") motor_gear();
    }
}

module frame_complete() {
    translate([0, 2, 0]) rotate([90, 90, 0]) bearing_frame(include_bearings = true);
    translate([0, -drum_len_mm - 2, 0]) rotate([-90, 90, 0]) bearing_frame(include_bearings = true);
    translate([0, 0, -drum_od_mm/2 - 25]) rotate([0, 0, 180]) color("#ff7777") chassis_2();
    translate([0, 0, -drum_od_mm/2 - 25]) rotate([0, 0, 180]) color("#77ff77") chassis_1();
}

rotate([90, 0, 0]) drum_complete();
motor_complete();
frame_complete();

color("#99999999") rotate([90, 0, 0]) drum();