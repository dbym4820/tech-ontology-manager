(in-package :cl-user)
(defpackage tom-asd
  (:use :cl :asdf))
(in-package :tom-asd)

(defsystem tom
  :version "0.1.3"
  :author "Tomoki Aburatani"
  :depends-on (:photon)
  :components ((:static-file "README.md")
	       (:file "tom"))
  :description "technology-ontology-manager"
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
