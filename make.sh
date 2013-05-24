#!/bin/sh

ruby run.rb --ts 5 --max-angle 80  -g 0.1 pencil.pov
# this should have created lots of .png files

ruby run.rb --ts 5 --make-brush 'my pencil'
