# encoding: UTF-8# encoding: UTF-8
# requires: parallel, rmagicks package

require 'RMagick'
include Magick

require 'parallel'

def pov_doc(x_tilt, y_tilt, tilt_factor)
text = <<EOF
#include "colors.inc"    // The include files contain
// #include "stones.inc"    // 
// #include "textures.inc"    // pre-defined scene elements
// #include "shapes.inc"
// #include "glass.inc"
// #include "metals.inc"
// #include "woods.inc"

#declare rotate_z = 0; // x-tilt (links)
#declare rotate_x = 0; // y-tilt (unten)

// background { color Black }

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
  function { 5 * ( u * u + v * v ) }
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
  fade_distance 5
  fade_power 1
  shadowless
}

EOF
text \
  .gsub(/rotate_z = .*/, "rotate_z = #{x_tilt * tilt_factor};") \
  .gsub(/rotate_x = .*/, "rotate_x = #{-y_tilt * tilt_factor};")
end

def s(s)
  system s
  raise "non zero exit code #{s}"if $? != 0
end

def render(output, size, doc)
  tmp_file = "/tmp/tmp.pov";
  File.open(tmp_file, "wb") { |file| file.write("#{doc}\n")}
  s "povray  -O#{output} +ua +H#{size} +W#{size} #{tmp_file} &> /dev/null"
end

ts = 3
ts_count = ts * 2 + 1
size = 150

s("rm img*.png || true")

list = []

img_nr = 0
for x_tilt in -ts..ts
  for y_tilt in -ts..ts
    list << ["img#{img_nr}.png", size, pov_doc(x_tilt, y_tilt, 60 / ts_count)]
    img_nr+=1
  end
end

puts "rendering"
Parallel.map(list, :in_processes=>4){|args| 
  render(*args)
  puts "."
}

puts "post processing"
list.each {|v|
  png = v[0]
  list = ImageList.new(png)
  # .quantize(256, GRAYColorspace)
  # level(0, 210)
  list.negate.normalize.write(png)
}
