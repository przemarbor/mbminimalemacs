;; (use-package emacs
;; :config

;; # ****** Tangle the specific (pointed) block of code
(defun mb/org-babel-tangle-block()
  (interactive)
  (let ((current-prefix-arg '(4)))
     (call-interactively 'org-babel-tangle)
))


;; # ****** Tangle the block of code given by the name

(defun mb/org-babel-tangle-named-block(block-name)
  (interactive)
  (save-excursion 
   (org-babel-goto-named-src-block block-name)
    (mb/org-babel-tangle-block)) 
)


;; # ****** Tangle all (and only those) source code blocks that belong to a specific target file

;; https://emacs.stackexchange.com/questions/80174/how-to-tangle-only-source-code-blocks-that-belong-to-a-specific-target-file


(defun mb/tangle-file (tangle-file)
  (interactive "P")
  (run-hooks 'org-babel-pre-tangle-hook)
  ;; Possibly Restrict the buffer to the current code block
  (save-restriction
    (save-excursion
      (let ((block-counter 0)
        (org-babel-default-header-args org-babel-default-header-args)
        path-collector)
    (mapc ;; map over file-names
     (lambda (by-fn)
       (let ((file-name (car by-fn)))
         (when file-name
               (let ((lspecs (cdr by-fn))
             (fnd (file-name-directory file-name))
             modes make-dir she-banged lang)
             ;; drop source-blocks to file
             ;; We avoid append-to-file as it does not work with tramp.
             (with-temp-buffer
           (mapc
            (lambda (lspec)
              (let* ((block-lang (car lspec))
                 (spec (cdr lspec))
                 (get-spec (lambda (name) (cdr (assq name (nth 4 spec)))))
                 (she-bang (let ((sheb (funcall get-spec :shebang)))
                         (when (> (length sheb) 0) sheb)))
                 (tangle-mode (funcall get-spec :tangle-mode)))
                (unless (string-equal block-lang lang)
              (setq lang block-lang)
              (let ((lang-f (org-src-get-lang-mode lang)))
                (when (fboundp lang-f) (ignore-errors (funcall lang-f)))))
                ;; if file contains she-bangs, then make it executable
                (when she-bang
              (unless tangle-mode (setq tangle-mode #o755)))
                (when tangle-mode
              (add-to-list 'modes (org-babel-interpret-file-mode tangle-mode)))
                ;; Possibly create the parent directories for file.
                (let ((m (funcall get-spec :mkdirp)))
              (and m fnd (not (string= m "no"))
                   (setq make-dir t)))
                ;; Handle :padlines unless first line in file
                (unless (or (string= "no" (funcall get-spec :padline))
                    (= (point) (point-min)))
              (insert "\n"))
                (when (and she-bang (not she-banged))
              (insert (concat she-bang "\n"))
              (setq she-banged t))
                (org-babel-spec-to-string spec)
                (setq block-counter (+ 1 block-counter))))
            lspecs)
           (when make-dir
             (make-directory fnd 'parents))
                   (unless
                       (and (file-exists-p file-name)
                            (let ((tangle-buf (current-buffer)))
                              (with-temp-buffer
                                (insert-file-contents file-name)
                                (and
                                 (equal (buffer-size)
                                        (buffer-size tangle-buf))
                                 (= 0
                                    (let (case-fold-search)
                                      (compare-buffer-substrings
                                       nil nil nil
                                       tangle-buf nil nil)))))))
                     ;; erase previous file
                     (when (file-exists-p file-name)
                       (delete-file file-name))
             (write-region nil nil file-name)
             (mapc (lambda (mode) (set-file-modes file-name mode)) modes))
                   (push file-name path-collector))))))
       (org-babel-tangle-collect-blocks nil tangle-file))
    (message "Tangled %d code block%s from %s" block-counter
         (if (= block-counter 1) "" "s")
         (file-name-nondirectory
          (buffer-file-name
           (or (buffer-base-buffer)
                       (current-buffer)
                       (and (org-src-edit-buffer-p)
                            (org-src-source-buffer))))))
    ;; run `org-babel-post-tangle-hook' in all tangled files
    (when org-babel-post-tangle-hook
      (mapc
       (lambda (file)
         (org-babel-with-temp-filebuffer file
           (run-hooks 'org-babel-post-tangle-hook)))
       path-collector))
        (run-hooks 'org-babel-tangle-finished-hook)
    path-collector))))


;; # ******* Tangle and close buffers opened during the tangling process

(defun mb/tangle-file-and-close-new-buffers (target-file)
  "Tangle code and close any buffers that were opened during the tangling process."
  (let ((initial-buffers (buffer-list)))  ;; List of buffers before tangling
    ;; Perform tangling operation
    (mb/tangle-file target-file)
    ;; Identify new buffers opened during tangling
    (dolist (buf (buffer-list))
      (unless (member buf initial-buffers)
        (kill-buffer buf)))))  ;; Close only buffers that weren't in the initial list

;; # ******* Tangle to target file 
  (defun mb/org-babel-tangle-to-target-file-from-the-file (file target-file)
    (interactive "fFile to tangle: \nP")
      (let* ((visited (find-buffer-visiting file))
	     (buffer (or visited (find-file-noselect file))))
	(prog1
	    (with-current-buffer buffer
	      (org-with-wide-buffer
	       (mapcar #'expand-file-name
		       (mb/tangle-file target-file))))
	  (unless visited (kill-buffer buffer)))))

;; # ******* Tangle to target file and clean up the mess

  (defun mb/org-babel-tangle-to-target-file-from-the-file-and-clean (file target-file)
    (interactive "fFile to tangle: \nP")
      (let* ((visited (find-buffer-visiting file))
	     (buffer (or visited (find-file-noselect file))))
	(prog1
	    (with-current-buffer buffer
	      (org-with-wide-buffer
	       (mapcar #'expand-file-name
		       (mb/tangle-file-and-close-new-buffers target-file))))
	  (unless visited (kill-buffer buffer)))))

;; # ****** Export given org-file to pdf (latex)

  (defun mb/org-babel-export-org-file-to-latex (filename)
    (interactive "fFile to export: \nP")
      (let* ((visited (find-buffer-visiting filename))
	     (buffer (or visited (find-file-noselect filename))))
	(prog1
	    (with-current-buffer buffer
	       (org-latex-export-to-pdf nil) )
	  (unless visited (kill-buffer buffer)))))

;; # ****** Tangle AND export org-file to pdf

  (defun mb/org-babel-tangle-and-export (file target-file)
    (interactive)
    ; (mb/org-babel-tangle-to-target-file-from-the-file file target-file)
    (mb/org-babel-tangle-to-target-file-from-the-file-and-clean file target-file)
    (sleep-for 0.5)
    (mb/org-babel-export-org-file-to-latex target-file)
    )


;; ****** Tangle AND export named-block to pdf

  (defun mb/org-babel-tangle-and-export-by-name (block-name)
    (interactive)
    (mb/org-babel-tangle-named-block block-name) 
    (sleep-for 0.5)
    (let ((target-file (concat block-name ".org")))
        (mb/org-babel-export-org-file-to-latex target-file)
    )
    )



;;****** Tangle and export target-block (name of the file where the block of code should be exported) from source-file to another file
;;[[~/projects/cissic.github.io/mysource/public-notes-org/2024-10-24-how-to-tangle-named-source-block-from-some-file-to-the-given-file.org]]


  (defun mb/tangle-from-file1-block-outputted-to-file2-and-export-target-to-latex-as-file3 (file1 targetfilename file3)
    (interactive)
    (let (
     (temp1-absolute (expand-file-name file1))
     (temp2-absolute (concat (expand-file-name (file-name-directory file1)) targetfilename))
     (temp3-absolute (expand-file-name file3))
     )

     ;  ; ;; ; ; (mb/org-babel-tangle-to-target-file-from-the-file temp1-absolute temp2)
     (mb/org-babel-tangle-to-target-file-from-the-file-and-clean temp1-absolute targetfilename)
     (rename-file temp2-absolute temp3-absolute t)
     (mb/org-babel-export-org-file-to-latex temp3-absolute)
    )
  )


;; (provide 'tangling-and-exporting)

;; )  ;; (use-package emacs
