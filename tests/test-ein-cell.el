(eval-when-compile (require 'cl))
(require 'ert)

(require 'ein-cell)


;;; ein:cell-from-json

(defun eintest:cell-json-data-code (prompt-number input &optional outputs)
  (list :cell_type "code"
        :input input
        :language "python"
        :outputs outputs
        :collapsed json-false
        :prompt_number prompt-number))

(defun eintest:cell-from-json (data &rest args)
  (let ((cell (apply #'ein:cell-from-json data args)))
    (should-not (ein:cell-active-p cell))
    cell))

(ert-deftest ein:cell-from-json-code ()
  (let* ((input-prompt-number 111)
         (output-prompt-number 222)
         (input (ein:join-str "\n" '("first input" "second input")))
         (output-0 (list :output_type "pyout"
                         :prompt_number output-prompt-number
                         :text (list "first output"
                                     "second output")))
         (data (eintest:cell-json-data-code
                input-prompt-number input (list output-0)))
         (cell (eintest:cell-from-json data)))
    (should (ein:codecell-p cell))
    (should (equal (oref cell :input-prompt-number) input-prompt-number))
    (should (equal (oref cell :input) input))
    (should (equal (car (oref cell :outputs)) output-0))
    (should (equal (oref cell :collapsed) nil))))

(ert-deftest ein:cell-from-json-text ()
  (let* ((input (ein:join-str "\n" '("first input" "second input")))
         (data (list :cell_type "text" :source input))
         (cell (eintest:cell-from-json data)))
    (should (ein:textcell-p cell))
    (should (equal (oref cell :input) input))))

(ert-deftest ein:cell-from-json-html ()
  (let* ((input (ein:join-str "\n" '("first input" "second input")))
         (data (list :cell_type "html" :source input))
         (cell (eintest:cell-from-json data)))
    (should (ein:htmlcell-p cell))
    (should (equal (oref cell :input) input))))

(ert-deftest ein:cell-from-json-markdown ()
  (let* ((input (ein:join-str "\n" '("first input" "second input")))
         (data (list :cell_type "markdown" :source input))
         (cell (eintest:cell-from-json data)))
    (should (ein:markdowncell-p cell))
    (should (equal (oref cell :input) input))))

(ert-deftest ein:cell-from-json-rst ()
  (let* ((input (ein:join-str "\n" '("first input" "second input")))
         (data (list :cell_type "rst" :source input))
         (cell (eintest:cell-from-json data)))
    (should (ein:rstcell-p cell))
    (should (equal (oref cell :input) input))))


;;; ein:cell-convert/copy

(ert-deftest ein:cell-convert-code-to-markdown ()
  (let* ((input-prompt-number 111)
         (output-prompt-number 222)
         (input (ein:join-str "\n" '("first input" "second input")))
         (output-0 (list :output_type "pyout"
                         :prompt_number output-prompt-number
                         :text (list "first output"
                                     "second output")))
         (data (eintest:cell-json-data-code
                input-prompt-number input (list output-0)))
         (dummy-ewoc (ewoc-create 'dummy))
         (old (eintest:cell-from-json data :ewoc dummy-ewoc))
         (new (ein:cell-convert old "markdown")))
    (should (ein:codecell-p old))
    (should (ein:markdowncell-p new))
    (should (equal (oref new :input) input))))

(ert-deftest ein:cell-convert-markdown-to-code ()
  (let* ((input (ein:join-str "\n" '("first input" "second input")))
         (dummy-ewoc (ewoc-create 'dummy))
         (data (list :cell_type "markdown" :source input))
         (old (eintest:cell-from-json data :ewoc dummy-ewoc))
         (new (ein:cell-convert old "code")))
    (should (ein:markdowncell-p old))
    (should (ein:codecell-p new))
    (should (equal (oref new :input) input))))

(ert-deftest ein:cell-copy-code ()
  (let* ((input-prompt-number 111)
         (output-prompt-number 222)
         (input (ein:join-str "\n" '("first input" "second input")))
         (output-0 (list :output_type "pyout"
                         :prompt_number output-prompt-number
                         :text (list "first output"
                                     "second output")))
         (data (eintest:cell-json-data-code
                input-prompt-number input (list output-0)))
         (dummy-ewoc (ewoc-create 'dummy))
         (old (eintest:cell-from-json data :ewoc dummy-ewoc))
         (new (ein:cell-copy old)))
    (should (ein:codecell-p old))
    (should (ein:codecell-p new))
    (should-not (equal (oref old :cell-id)
                       (oref new :cell-id)))
    (should (equal (oref old :input) input))
    (should (equal (oref new :input) input))))

(ert-deftest ein:cell-copy-text-types ()
  (loop for cell-type in '("text" "html" "markdown" "rst")
        for cell-p = (intern (format "ein:%scell-p" cell-type))
        do
        (let* ((input (ein:join-str "\n" '("first input" "second input")))
               (data (list :cell_type cell-type :source input))
               (dummy-ewoc (ewoc-create 'dummy))
               (old (eintest:cell-from-json data :ewoc dummy-ewoc))
               (new (ein:cell-copy old)))
          (should (funcall cell-p old))
          (should (funcall cell-p new))
          (should-not (equal (oref old :cell-id)
                       (oref new :cell-id)))
          (should (equal (oref old :input) input))
          (should (equal (oref new :input) input)))))


;;; ein:cell-element-get

(ert-deftest ein:cell-element-get-basecell ()
  (let ((cell (ein:basecell "Cell")))
    ;; it's not supported
    (should-error (ein:cell-element-get :prompt))))

(ert-deftest ein:cell-element-get-codecell ()
  (let* ((element (list :prompt 1
                        :input 2
                        :output '(3 4)
                        :footer 5))
         (cell (ein:cell-from-type "code" :element element)))
    (mapc (lambda (kv)
            (should (equal (ein:cell-element-get cell (car kv)) (cdr kv))))
          (ein:plist-iter element))
    (should (equal (ein:cell-element-get cell :output 0) 3))
    (should (equal (ein:cell-element-get cell :output 1) 4))
    (should (equal (ein:cell-element-get cell :output 2) nil))
    (should (equal (ein:cell-element-get cell :after-input) 3))
    (should (equal (ein:cell-element-get cell :after-output) 5))
    (should (equal (ein:cell-element-get cell :before-input) 1))
    (should (equal (ein:cell-element-get cell :before-output) 2))
    (should (equal (ein:cell-element-get cell :last-output) 4))))

(ert-deftest ein:cell-element-get-codecell-no-ouput ()
  (let* ((element (list :prompt 1
                        :input 2
                        :footer 5))
         (cell (ein:cell-from-type "code" :element element)))
    (mapc (lambda (kv)
            (should (equal (ein:cell-element-get cell (car kv)) (cdr kv))))
          (ein:plist-iter element))
    (should (equal (ein:cell-element-get cell :after-input) 5))
    (should (equal (ein:cell-element-get cell :last-output) 2))))

(ert-deftest ein:cell-element-get-textcell ()
  (let* ((element (list :prompt 1
                        :input 2
                        :footer 5))
         (cell (ein:cell-from-type "text" :element element)))
    (mapc (lambda (kv)
            (should (equal (ein:cell-element-get cell (car kv)) (cdr kv))))
          (ein:plist-iter element))
    (should (equal (ein:cell-element-get cell :after-input) 5))
    (should (equal (ein:cell-element-get cell :before-input) 1))))