# encoding: UTF-8# encoding: UTF-8
# requires: parallel, rmagicks package

require 'RMagick'
require "optparse"
include Magick

require 'parallel'

def pov_doc(args)

  texture = <<-EOF

    #declare gradient_height = 0.5;

    pigment {
      function { clip(1- ((gradient_height-y)/gradient_height),0,1) }
    }
    finish {
      ambient 1
    }
  EOF

  camera = case args[:view]
  when "x"
    <<-EOF
     camera {
      orthographic
      location <3, 0.5, 0>
      look_at  <0, 0.2,  0>
    }

    disc { <0,0,0>, <0,2,0>, 1, 0.4 }
    disc { <0,1,0>, <0,2,0>, 1, 0.4 }
    EOF
  when "z"
    <<-EOF
    camera {
      orthographic
      location <0, 0.5, 3>
      look_at  <0, 0.2,  0>
    }

    disc { <0,0,0>, <0,2,0>, 1, 0.4 }
    disc { <0,1,0>, <0,2,0>, 1, 0.4 }
    EOF
  else
    <<-EOF
    #declare DISTANCE_NEAR = -0.2;
    #declare DISTANCE_FAR = 2;
    #declare CAMERA_POSITION = <0, -10, 0>;
    camera {
      orthographic
      angle 10
      right x*100/100
      location CAMERA_POSITION
      look_at  <0, 2,  0>
    }
    EOF
  end

text = <<EOF
#include "colors.inc"    // The include files contain
#include "transforms.inc"    // The include files contain
#
// #include "stones.inc"    // 
// #include "textures.inc"    // pre-defined scene elements
// #include "shapes.inc"
// #include "glass.inc"
// #include "metals.inc"
#include "math.inc"

#declare rotate_z = 0; // x-tilt (links)
#declare rotate_x = 0; // y-tilt (unten)
#{camera}

#{args[:object]}
// light_source { 
//   <0, -5, 0> 
//   color White
//   fade_distance 5
//   fade_power 1
//   shadowless
// }

EOF
text \
  .gsub(/rotate_z = .*/, "rotate_z = #{args[:max_angle_x] * args[:x_tilt]};") \
  .gsub(/rotate_x = .*/, "rotate_x = #{-args[:max_angle_y] * args[:y_tilt]};") \
  .gsub('TEXTURE', texture)
end

def s(s)
  puts "running #{s}"
  system s
  raise "non zero exit code #{s}"if $? != 0
end

def render(args)
  tmp_file = "/tmp/#{args[:out]}.pov";
  File.open(tmp_file, "wb") { |file| file.write("#{args[:pov_doc]}\n")}
  cmd = "povray  -O#{args[:out]} +ua +H#{args[:size]} +W#{args[:size]} #{tmp_file} &> /dev/null"
  puts cmd
  s cmd
end

ts = 3
options = {}
OptionParser.new do |opts|
  opts.banner = "ruby run.rb [--view x|z] [--ts N] tip.pov"

  opts.on("-v", "--view [x|z]", ["x", "z", "x,z"], "select side view (debugging tip)") do |v| options[:view] = v end
  opts.on("-d", "--ts [N]", Integer, "number images for each tilt dimension: 2*ts+1") do |v| ts = v end
  opts.on("-s", "--size [N]", Integer, "width of square image") do |v| ts = v end

  opts.on(nil, "--max-angle [N]", Integer, "max-angle") do |v| options[:max_angle_y] = v; options[:max_angle_x] = v end

  opts.on(nil, "--max-angle-x [N]", Integer, "max-angle") do |v| options[:max_angle_y] = v end
  opts.on(nil, "--max-angle-y [N]", Integer, "max-angle") do |v| options[:max_angle_x] = v end

  opts.on("-X", "--x_tilt [0-1]", Float, "max-angle") do |v| options[:x_tilt] = v end
  opts.on("-Y", "--y_tilt [0-1]", Float, "max-angle") do |v| options[:y_tilt] = v end


  opts.on(nil, "--debug") do |v| options[:debug] = true end
end.parse!


options[:size] ||= 150
options[:max_angle_x] ||= 50
options[:max_angle_y] ||= 50

options[:x_tilt] ||= 0
options[:y_tilt] ||= 0

puts options

puts "pov file is #{ARGV[0]}"
options[:object] = File.open(ARGV[0], "rb").read


list = []

if options[:view]

  for view in options[:view].split(",")
    puts "rendering side view"
    options[:view] = view
    options[:out] = "side#{options[:view]}.png"

    options[:pov_doc] = pov_doc(options)
    list << options.clone
  end

  # also create one default view (bottom)
  options.delete(:view)
  ts = 0
end

ts_count = ts * 2 + 1

s("rm img*.png || true")
s("rm side*.png || true")

img_nr = 0
for x_tilt in -ts..ts
  for y_tilt in -ts..ts
    options[:x_tilt] = ts == 0 ? 0 : x_tilt / ts
    options[:y_tilt] = ts == 0 ? 0 : y_tilt / ts
    options[:pov_doc] = pov_doc(options)
    options[:out] = "img#{img_nr}.png"
    list << options.clone
    img_nr+=1
  end
end

puts "rendering"
Parallel.map(list, :in_processes=>4){|args| 
  render(args)
  puts "."
}

puts "post processing"
list.each {|v|
  png = v[:out]
  list = ImageList.new(png)
  # .quantize(256, GRAYColorspace)
  # level(0, 210)
  list.negate.normalize.write(png)
}

puts "total images: #{ts_count * ts_count}, dimension: #{ts_count}"
