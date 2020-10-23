(in-package :cl-user)
(defpackage tom-asd
  (:use :cl :asdf))
(in-package :tom-asd)

(defsystem tom
  :version "0.1.3"
  :author "Tomoki Aburatani"
  :license :MIT
  :depends-on (:jonathan
	       :clack
	       :split-sequence
	       :alexandria
	       :optima
	       :babel
	       :photon)
  :serial t
  :components ((:static-file "LICENSE")
	       (:static-file "README.md")
	       (:module "src"
                :components
                ((:file "tom"))))
  :description "Auto question feedback agent"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.md"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (test-op tom-test))))
