// from http://www.povray.org/documentation/view/3.6.1/62/

#declare my_prism = 
prism {
  cubic_spline
  0, // sweep the following shape from here ...
  1, // ... up through here
  6, // the number of points making up the shape ...
  < 3, -5>, // point#1 (control point... not on curve)
  < 3,  5>, // point#2  ... THIS POINT ...
  <-5,  0>, // point#3
  < 3, -5>, // point#4
  < 3,  5>, // point#5 ... MUST MATCH THIS POINT
  <-5,  0>  // point#6 (control point... not on curve)
 translate <1.5, 0, 0>
 scale 0.15
 rotate <0, 0, 90>
 translate <0, 1, 0>

 rotate <rotate_x / 2, 0, rotate_z /2>
 rotate <rotate_x / 2, 0, rotate_z /2>

 translate <0, Z_CORRECTION, 0>
};

object {
  my_prism
  TEXTURE
}
