Idea:

1) create a 3d brush tip
2) try to find an approximate way to create a brush base don the pressure the
   tip would create on paper
3) with 2) create a gimp animated brush with x-tilt/y-tilt support


Implementation details:
=======================
2) this is done by illuminating the tip with a light fading out using povray
I was too lazy to start learning any 3d library.


How to create the brush:
see make.sh
the second command outputs scheme code you can run in gimp script console, eg
when running gimp -b - (terminal)

The export may not work (yet), but you can export the layers manually then.

how to create a brush manually:

1) ruby run.rb "prism.pov", you should get lots of *.png files

2) copy post-process-brush-layers.scm to ~/.config/gimp-2.9/brushes
3) in gimp open png files as layers (one image)
  run the post-process-brush-layers script
  (optoinal)
4) try saving as pencil.gih:

ts number of images to be rendered for each dimenios, see run.rb

  number of cells: (ts*2+1)^2   
  dimension: 2
  ranks: (ts*2+1) (tilt-x)
  ranks: (ts*2+1) (tilt-y)

debugging objects:

eg discs can help to see the plane:
// disc { <0,0,0>, <0,2,0>, 1, 0.4 }
// disc { <0,1,0>, <0,2,0>, 1, 0.4 }


thanks to
============
the gimp team for helping me, epsecially nomis
