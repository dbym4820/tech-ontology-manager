#|
  This file is a part of dart project.
  Copyright (c) 2017 Tomoki Aburatani (aburatanitomoki@gmail.com)
|#

(in-package :cl-user)
(defpackage tom-test-asd
  (:use :cl :asdf))
(in-package :tom-test-asd)

(defsystem tom-test
  :author "Tomoki Aburatani"
  :license "MIT"
  :depends-on (:tom
               :prove)
  :components ((:module "t"
                :components
                ((:test-file "tom"))))
  :description "Test system for tom"

  :defsystem-depends-on (:prove-asdf)
  :perform (test-op :after (op c)
                    (funcall (intern #.(string :run-test-system) :prove-asdf) c)
                    (asdf:clear-system c)))
