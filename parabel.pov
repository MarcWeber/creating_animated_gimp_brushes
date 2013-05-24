parametric {
  function { u }
  function { 5 * ( u * u + v * v ) }
  function { v }

  <-80,-80>, <80, 80>
  contained_by { sphere{0, 5} }
  // max_gradient ??
  accuracy 0.1
  precompute 10 x,y,z

  rotate <rotate_x / 2, 0, rotate_z /2>
  rotate <rotate_x / 2, 0, rotate_z /2>

  TEXTURE
}
