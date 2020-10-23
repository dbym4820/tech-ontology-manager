(in-package :cl-user)
(defpackage tom
  (:use :cl)
  (:import-from :photon :init :delete-photon-directory)
  (:import-from :jonathan :to-json)
  (:import-from :split-sequence :split-sequence)
  (:export :tom))
(in-package :tom)

(defun help ()
  (format nil "usage: tom"))

(defun tom (tom-command &optional tom-option)
  (labels ((tom-cond (command-list)
	     (find tom-command command-list :test #'string=)))
    (cond ((tom-cond '("concept-name" "--concept-name"))
	   (find-concept-from-string tom-option))
	  ((tom-cond '("concept-id" "--concept-id"))
	   (find-concept-from-id tom-option))
	  ((tom-cond '("start-server" "--start-server"))
	   (start-server))
	  ((tom-cond '("init" "--init"))
	   (tom-initialize))
	  ((tom-cond '("help" "--help")) (help))
          (t (help)))))

(defun tom-initialize ()
  ;;(delete-photon-directory)
  (photon:init :update t)
  (let ((ontology-repository "dbym4820/ontologies/technology-ontology/v20200614"))
    (photon:install ontology-repository)))

(defun find-concept-from-string (arg)
  (let* ((concept-info (photon:find-concept arg))
	 (concept-name (photon:concept-name concept-info))
	 (concept-id (photon:concept-id concept-info))
	 (properties (mapcar #'photon:concept-name (remove-if #'null (photon:property-list concept-info))))
	 (is-instance (if (photon:instantiation concept-info) "true" "false"))
	 (parent-concept (photon:concept-name (photon:parent-concept concept-info)))
	 (child-concepts (mapcar #'photon:concept-name (photon:child-concept-list concept-info))))
    (format nil "~A"
	    (to-json
	     `(("id" . ,concept-id)
	       ("concept-name" . ,concept-name)
	       ("is-instance" . ,is-instance)
	       ("properties" . ,properties)
	       ("parent-concept" . ,parent-concept)
	       ("child-concepts" . ,child-concepts))
	     :from :alist))))

  
(defun find-concept-from-id (arg)
  (let* ((concept-info (photon:find-concept-from-id arg))
	 (concept-name (photon:concept-name concept-info))
	 (concept-id (photon:concept-id concept-info))
	 (properties (mapcar #'photon:concept-name (remove-if #'null (photon:property-list concept-info))))
	 (is-instance (if (photon:instantiation concept-info) "true" "false"))
	 (parent-concept (photon:concept-name (photon:parent-concept concept-info)))
	 (child-concepts (mapcar #'photon:concept-name (photon:child-concept-list concept-info))))
    (format nil "~A"
	    (to-json
	     `(("id" . ,concept-id)
	       ("concept-name" . ,concept-name)
	       ("is-instance" . ,is-instance)
	       ("properties" . ,properties)
	       ("parent-concept" . ,parent-concept)
	       ("child-concepts" . ,child-concepts))
	     :from :alist))))


(defparameter *server* nil)
(defun start-server ()
  (setf *server*
	(clack:clackup
	 (lambda (req)
	   (index req))))
  (loop))
(defun stop-server ()
  (clack:stop *server*))
  

(defun index (env)
  `(200 (:content-type "application/json"
	 :access-control-allow-origin "*")
	,(list
	  (tom
	   (subseq (getf env :path-info) 1)
	   (char-check (getf env :query-string))))))

(defun char-check (str)
  (let ((d
 	  (subseq str
		  (1+ (or (position "="
				    str
				    :test #'string=)
			  -1)))))
    (convert-char-code d)))

(defun convert-char-code (char-string)
  (let ((target-octets
  	  (mapcar #'char-convert
		  (remove-if #'(lambda (s)
				 (or (null s) (string= s "22")))
			     (split-sequence #\% char-string :start 1)))))
    (babel:octets-to-string
     (make-array (length target-octets)
     		 :element-type '(unsigned-byte 8)
     		 :initial-contents target-octets)
     :encoding :utf-8)))


(defun char-convert (char-code)
  (let* ((codes '(("A" 10) ("B" 11) ("C" 12) ("D" 13) ("E" 14) ("F" 15)))
	 (10th-grade (subseq char-code 0 1))
	 (1st-grade (subseq char-code 1 2))
	 (true-10th
	   (if (find 10th-grade codes :key #'car :test #'string=)
	       (second (find 10th-grade codes :key #'car :test #'string=))
	       (parse-integer 10th-grade))) ;; 10のくらいが文字だったら
	 (true-1st
	   (if (find 1st-grade codes :key #'car :test #'string=)
	       (second (find 1st-grade codes :key #'car :test #'string=))
	       (parse-integer 1st-grade))))
    (+ (* true-10th 16) true-1st)))


(tom-initialize)
