drum_od_mm = 80;
drum_id_mm = 76.5;
drum_len_mm = 100;
ring_gear_radius_offset_mm = 0.5;

ring_gear_n = 90;
motor_gear_n = 18;

bearing_post_diameter = 7.8;

motor_angle = 30;

$fn = 64;

// ---

disable_individual_models = 0;

drum_motor_center_distance = (ring_gear_n + motor_gear_n + 2) / 2;

module drum() {
    difference() {
        cylinder(d = drum_od_mm, h = drum_len_mm);
        translate([0, 0, -1]) cylinder(d = drum_id_mm, h = drum_len_mm + 2);
    }
}


// ---


include <PolyGear/PolyGearBasics.scad>

function herringbone(helix=30, $fn=9) = let(n=floor($fn/2)) 
  concat( lst_repeat(-helix, n),[0],lst_repeat(helix, n) );

module spur_gear(
//basic options
  n = 16,  // number of teeth
  m = 1,   // module
  z = 1,   // thickness
  pressure_angle = 20,
  helix_angle    = 0,   // the sign gives the handiness, can be a list
  backlash       = 0.1, // in module units
//shortcuts
  w  = undef, //overrides z when defined
  a0 = undef, //overrides pressure angle when defined
  b0 = undef, //overrides helix angle when defined
  tol= undef, //overrides backlash
//advanced options
  chamfer       = 0, // degrees, should be in [0:90[
  chamfer_shift = 0, // from the pitch radius in module units
  add = 0, // add to addendum
  ded = 0, // subtract to the dedendum
  x   = 0, // profile shift
  type= 1, //-1: internal 1: external. In practice it flips the sing of the profile shift
//finesse options
  $fn=5,     // tooth profile subdivisions
) {
  z = is_undef(w) ? z : w;
  pressure_angle = is_undef(a0) ? pressure_angle : a0;
  helix_angle    = let(hlx = is_undef(b0) ? helix_angle : b0) 
                     is_list(hlx) ? hlx : [hlx, hlx];
  backlash       = is_undef(tol) ? backlash : tol; // in module units
  fz = len(helix_angle);
  pts = flatten([ for (i=[0:fz-1]) let(zi= z*i/(fz-1) - z/2) gear_section(
    n=n, m=m, z=zi,
    pressure_angle = pressure_angle, helix_angle = helix_angle[i], backlash = backlash,
    add = add, ded = ded, x = x, type = type, $fn=$fn
  )]);
  Nlay = len(pts)/fz;
  side = make_side_faces(Nlay, fz);
  caps = make_cap_faces(Nlay, fz, n);
  if (chamfer == 0) polyhedron(points=pts, faces=concat(side, caps), convexity = 3);
  else render(10) I() {
    polyhedron(points=pts, faces=concat(side, caps));
    MKz() let(t = chamfer, rc = m*n/2 + m*chamfer_shift) 
      Cy(r1=z/2/tan(t)+rc, r2=0, h=rc*tan(t)+z/2, C=0, $fn=n);
  }
}

