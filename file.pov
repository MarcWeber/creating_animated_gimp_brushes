#include "colors.inc"    // The include files contain
// #include "stones.inc"    // 
// #include "textures.inc"    // pre-defined scene elements
// #include "shapes.inc"
// #include "glass.inc"
// #include "metals.inc"
// #include "woods.inc"

#declare rotate_z = 0; // x-tilt (links)
#declare rotate_x = 0; // y-tilt (unten)

background { color Black }

camera {
  orthographic
  angle 40
  right x*100/100
  location <0, -10, 0>
  look_at  <0, 2,  0>
}

// camera {
//  orthographic
//  location <10, 0, 0>
//  look_at  <0, 2,  0>
//}

// sphere {
//   <0, 2, 0>, 1
//   texture {
//     pigment { color White }
//   }
// }

parametric {
  function { u }
  function { u * u + v * v }
  function { v }

  <-80,-80>, <80, 80>
  contained_by { sphere{0, 30} }
  // max_gradient ??
  accuracy 0.1
  precompute 10 x,y,z
  pigment {rgb 1}

 rotate <rotate_x / 2, 0, rotate_z /2>
 rotate <rotate_x / 2, 0, rotate_z /2>
}

light_source { 
  <0, -5, 0> 
  color White
  fade_distance 10
  fade_power 1
  shadowless
}
