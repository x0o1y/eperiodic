;;; eperiodic-tests.el --- Tests for eperiodic -*- lexical-binding: t; -*-

(require 'ert)

(load (expand-file-name
       "eperiodic.el"
       (file-name-directory (or load-file-name buffer-file-name)))
      nil t)

(ert-deftest eperiodic-test-period-law ()
  (should (equal (mapcar #'eperiodic-period-length
                         (number-sequence 1 8))
                 '(2 2 8 8 18 18 32 32)))
  (should (equal (mapcar (lambda (Period)
                           (cons (eperiodic-period-start Period)
                                 (eperiodic-period-end Period)))
                         (number-sequence 1 8))
                 '((1 . 2) (3 . 4) (5 . 12) (13 . 20)
                   (21 . 38) (39 . 56) (57 . 88) (89 . 120)))))

(ert-deftest eperiodic-test-default-view ()
  (should (eq (default-value 'eperiodic-display-type) 'adomah))
  (should (eq (default-value 'eperiodic-adomah-orientation) 'left)))

(ert-deftest eperiodic-test-period-orbitals ()
  (should (equal (eperiodic-period-orbitals 1) '(1s)))
  (should (equal (eperiodic-period-orbitals 5) '(3d 4p 5s)))
  (should (equal (eperiodic-period-orbitals 8) '(5f 6d 7p 8s))))

(ert-deftest eperiodic-test-adomah-coordinates ()
  (should (equal (eperiodic-adomah-coordinate 1) '(0 . 33)))
  (should (equal (eperiodic-adomah-coordinate 2) '(0 . 34)))
  (should (equal (eperiodic-adomah-coordinate 5) '(1 . 26)))
  (should (equal (eperiodic-adomah-coordinate 21) '(2 . 15)))
  (should (equal (eperiodic-adomah-coordinate 57) '(3 . 0)))
  (should (equal (eperiodic-adomah-coordinate 118) '(6 . 31)))
  (should (equal (eperiodic-adomah-coordinate 119) '(7 . 33)))
  (should (equal (eperiodic-adomah-coordinate 120) '(7 . 34))))

(ert-deftest eperiodic-test-adomah-orientations ()
  (should (equal (eperiodic-adomah-dimensions 'up) '(8 . 35)))
  (should (equal (eperiodic-adomah-dimensions 'left) '(35 . 8)))
  (should (equal
           (eperiodic-adomah-transform-coordinate '(3 . 0) 'up)
           '(3 . 0)))
  (should (equal
           (eperiodic-adomah-transform-coordinate '(3 . 0) 'right)
           '(34 . 3)))
  (should (equal
           (eperiodic-adomah-transform-coordinate '(3 . 0) 'down)
           '(4 . 34)))
  (should (equal
           (eperiodic-adomah-transform-coordinate '(3 . 0) 'left)
           '(0 . 3)))
  (should (equal
           (eperiodic-adomah-transform-coordinate
            (eperiodic-adomah-coordinate 1) 'left)
           '(33 . 0)))
  (should (equal
           (eperiodic-adomah-transform-coordinate
            (eperiodic-adomah-coordinate 57) 'left)
           '(0 . 3)))
  (should (equal
           (eperiodic-adomah-transform-coordinate
            (eperiodic-adomah-coordinate 89) 'left)
           '(0 . 4))))

(ert-deftest eperiodic-test-adomah-cells ()
  (let ((eperiodic-adomah-orientation 'up))
    (should (= (length (eperiodic-adomah-cells)) 120))
    (should (equal (assq 57 (eperiodic-adomah-cells)) '(57 3 0)))))

(ert-deftest eperiodic-test-predicted-elements ()
  (should (equal (eperiodic-get-element-property 119 'symbol) "Uu"))
  (should (equal (eperiodic-get-element-property 120 'symbol) "Ub"))
  (should (eq (eperiodic-get-orbital-from-z 120) '8s))
  (should (equal (eperiodic-get-element-property
                  119 'electronic-configuration)
                 "[Og] 8s-1 ")))

(ert-deftest eperiodic-test-adomah-render ()
  (dolist (orientation '(up right down left))
    (with-temp-buffer
      (eperiodic-mode)
      (setq eperiodic-display-type 'adomah
            eperiodic-adomah-orientation orientation
            eperiodic-last-displayed-element 57)
      (eperiodic-display)
      (let ((position
             (text-property-any (point-min) (point-max)
                                'eperiodic-at-number 57))
            (elements
             (cl-loop for z from 1 to 120
                      count (text-property-any
                             (point-min) (point-max)
                             'eperiodic-at-number z))))
        (should (= elements 120))
        (should position)
        (should (equal (get-text-property position 'eperiodic-at-number) 57))
        (should (equal
                 (buffer-substring-no-properties position (+ position 2))
                 "La"))
        (let ((predicted
               (text-property-any (point-min) (point-max)
                                  'eperiodic-at-number 119)))
          (should (eq (get-text-property predicted 'face)
                      'eperiodic-s-block-face)))
        (should (marker-position eperiodic-element-end-marker))))))

(ert-deftest eperiodic-test-existing-layouts-render ()
  (dolist (display-type '(conventional ordered))
    (with-temp-buffer
      (eperiodic-mode)
      (setq eperiodic-display-type display-type
            eperiodic-last-displayed-element 1)
      (eperiodic-display)
      (should
       (text-property-any (point-min) (point-max)
                          'eperiodic-at-number 118)))))

(provide 'eperiodic-tests)

;;; eperiodic-tests.el ends here
