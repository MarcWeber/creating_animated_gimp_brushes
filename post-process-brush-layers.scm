; An example of how to create a floating layer and how to ancor it.
(define (post-process-brush-layers img drawable)

  (for-each
      (lambda (layer)
          (gimp-image-set-active-layer img layer)
          (let* (
                 (drawable (car (gimp-image-get-active-drawable img)))
                )
                (gimp-levels drawable 5 0 200 1.0 0 255)
                (plug-in-normalize 1 img drawable)
                ; (plug-in-colortoalpha 1 img drawable '(255 255 255))
          ))
      (vector->list (car (cdr (gimp-image-get-layers img))))
  )
)

(script-fu-register "post-process-brush-layers"
                    "post process brush image layers"
                    "Copy the selection into the same layer"
                    "Marc Weber"
                    "Marc Weber"
                    "2013-01-01"
                    "RGB*, GRAY*"
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Layer" 0)
(script-fu-menu-register "post-process-brush-layers" "<Image>/post-process-brush-layers")
