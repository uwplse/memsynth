#lang rosette

(require ocelot
         "base.rkt")


; Some assertions we expect to be true
(assert (allowed? RMO test/madorhaim/L1))
(assert (allowed? RMO test/madorhaim/L2))
(assert (allowed? RMO test/madorhaim/L3))
(assert (not (allowed? RMO test/madorhaim/L4)))
(assert (allowed? RMO test/madorhaim/L5))
(assert (not (allowed? RMO test/madorhaim/L6)))
(assert (allowed? RMO test/madorhaim/L7))
(assert (allowed? RMO test/madorhaim/L8))
(assert (allowed? RMO test/madorhaim/L9))
(assert (not (allowed? TSO test/madorhaim/L1)))
(assert (not (allowed? TSO test/madorhaim/L2)))
(assert (not (allowed? TSO test/madorhaim/L3)))
(assert (not (allowed? TSO test/madorhaim/L4)))
(assert (not (allowed? TSO test/madorhaim/L5)))
(assert (not (allowed? TSO test/madorhaim/L6)))
(assert (allowed? TSO test/madorhaim/L7))
(assert (allowed? TSO test/madorhaim/L8))
(assert (not (allowed? TSO test/madorhaim/L9)))

; Solve to see if these assertions are possible
(define M (solve #t))

(cond
  [(sat? M)
   (printf "Found a solution:\n")
   (printf "~a\n" (ast->datum (simplify (evaluate sketch M))))]
  [else
   (printf "No solution.\n")])

