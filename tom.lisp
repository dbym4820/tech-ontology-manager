(in-package :cl-user)
(defpackage tom
  (:use :cl)
  (:import-from :photon :init :install :defphoton-route :launch-gui)
  (:export :tom))
(in-package :tom)

(defun tom (tom-command &optional tom-option)
  (labels ((tom-cond (command-list)
	     (find tom-command command-list :test #'string=)))
    (cond ((tom-cond '("all-concept" "--all-concept"))
	   (all-concept))
	  ((tom-cond '("concept-name" "--concept-name"))
	       (photon.server::find-concept-from-string tom-option))
	  ((Tom-cond '("concept-id" "--concept-id"))
	   (photon.server::find-concept-from-id tom-option))
	  ((tom-cond '("start-server" "--start-server"))
	   (launch-gui :start-server 5000))
	  ((tom-cond '("stop-server" "--stop-server"))
	   (launch-gui :stop-server))
	  ((tom-cond '("init" "--init"))
	   (tom-initialize))
	  ((tom-cond '("help" "--help")) (help))
          (t (help)))))

(defun tom-initialize ()
  ;;(delete-photon-directory)
  (init :update t)
  (let ((ontology-repository "dbym4820/ontologies/technology-ontology/v20200614"))
    (install ontology-repository)))

(defphoton-route "/" (params)
  (help))

(defphoton-route "/all-concept" (params)
  (all-concept))

(defphoton-route "/concept-name/:concept" (params)
  (format nil "~A"
	  (photon.server::find-concept-from-string
	   (cdr (assoc 'concept params :test #'string=)))))

(defphoton-route "/concept-id/:concept" (params)
  (format nil "~A"
	  (photon.server::find-concept-from-id
	   (cdr (assoc 'concept params :test #'string=)))))


(defun help ()
  (format nil "usage1 -> http://localhost:5000/concept-name/\"技術\"~%usage2 -> http://localhost:5000/concept-name/\"1587813689278_n2\""))

(defun all-concept ()
  (photon.server::to-json
   (cdr (photon:show-concepts))))


(tom-initialize)
