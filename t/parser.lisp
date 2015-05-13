(in-package :cl-user)
(defpackage clwgc-test.parser
  (:use :cl
        :prove
        :esrap
        :clwgc-test.init
        :clwgc.ast)
  (:import-from :clwgc.parser
                :whitespace
                :atom
                :string
                :list
                :sexp))
(in-package :clwgc-test.parser)

(plan nil)

(subtest "whitespace"
  (macrolet ((whitespace-test ((&rest characters) comment)
               `(is (parse 'whitespace (format nil "~{~a~}" ',characters))
                    nil
                    ,comment)))
    (whitespace-test (#\Space)
                     "wiht #\Space.")

    (whitespace-test (#\Newline)
                     "wiht #\Newline.")

    (whitespace-test (#\Tab)
                     "wiht #\Tab.")

    (whitespace-test (#\Space #\Space)
                     "with two whitespaces.")))

(subtest "atom"
  (macrolet ((atom-test (target expect comment)
               `(is-ast (parse 'atom ,target)
                        ,expect
                        ,comment)))
    (atom-test "1"
               (make-integer 1)
               "with integer.")

    (atom-test "1.1e0"
               (make-float 1.1e0)
               "with float.")

    (atom-test "test"
               (make-sym "test")
               "with symbol.")))

(subtest "string"
  (is-ast (parse 'string "\"test\"")
          (make-str "test")
          "ok."))

(subtest "list"
  (subtest "pair"
    (is-ast (parse 'list "(1 . 2)")
            (make-cons (make-integer 1) (make-integer 2))
            "ok."))

  (subtest "length = 1"
    (is-ast (parse 'list "(1)")
            (make-cons (make-integer 1) *nil*)
            "without specified NIL.")

    (is-ast (parse 'list "(1 nil)")
            (make-cons (make-integer 1) *nil*)
            "with specified NIL."))
  
  (subtest "length > 1"
    (is-ast (parse 'list "(1 2)")
            (make-lst (make-integer 1) (make-integer 2))
            "without NIL.")

    (is-ast (parse 'list "(1 2 nil)")
            (make-lst (make-integer 1) (make-integer 2) *nil*)
            "with NIL.")))

(subtest "sexp"
  (macrolet ((sexp-test (target expect comment)
               `(is-ast (parse 'sexp ,target)
                        ,expect
                        ,comment)))
    (sexp-test "1"
               (make-integer 1)
               "with atom.")

    (sexp-test "\"test\""
               (make-str "test")
               "with string.")

    (sexp-test "(1 2)"
               (make-lst (make-integer 1) (make-integer 2))
               "with list.")))

(subtest "parse"
  (is-ast (clwgc.parser:parse "(1 2)")
          (make-lst (make-integer 1) (make-integer 2))
          "ok."))

(finalize)
