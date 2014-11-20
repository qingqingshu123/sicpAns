(load "2049_painters.scm")

(define (flip-horiz painter)
   (transform-painter painter
     (make-vect 1.0 0.0)
     (make-vect 0.0 0.0)
     (make-vect 1.0 1.0)))
(define (flip-ccw180 painter)
   (transform-painter painter
     (make-vect 1.0 1.0)
     (make-vect 0.0 1.0)
     (make-vect 1.0 0.0)))
(define (flip-ccw270 painter)
   (transform-painter painter
     (make-vect 0.0 1.0)
     (make-vect 0.0 0.0)
     (make-vect 1.0 1.0)))
(define (transform-painter painter origin corner-x corner-y)
  (lambda (frame)
    (let ((m (frame-coord-map frame)))
      (let ((new-origin (m origin)))
        (painter (make-frame
                   new-origin
                   (sub-vect (m corner-x) new-origin)
                   (sub-vect (m corner-y) new-origin)))))))