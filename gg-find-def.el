;;; gg-find-def.el --- Find definition in git repository using git grep -*- lexical-binding: t -*-

;; Copyright © 2016 Tijs Mallaerts
;;
;; Author: Tijs Mallaerts <tijs.mallaerts@gmail.com>

;; Package-Requires: ((emacs "24.3"))

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;; The gg-find-def function will try to find the definition of the
;; symbol at point in the git repository using git grep.  If more than
;; 1 candidate is found, the list of candidates will be displayed.
;; The search terms and input function are customizable per file
;; extension.

;;; Code:

(defgroup gg-find-def nil
  "Git grep find definition customizations."
  :group 'convenience)

(defcustom gg-find-def-extension-search-terms
  '(("clj" . ("defn %s" "defmacro %s" "def %s"))
    ("el" . ("defun %s" "defmacro %s" "defvar %s" "defcustom %s"))
    ("js" . ("function %s" "%s: function"))
    ("php" . ("function %s")))
  "Controls the search terms per file extension.
The search terms describe how a possible definition can be found.
They are stored in a list, and each search term is a string
that has to contain a %s string argument that will be replaced
by the return value of the input function defined by the
`gg-find-def-extension-input-fns' variable."
  :type '(alist :key-type string :value-type (repeat string))
  :group 'gg-find-def)

(defcustom gg-find-def-extension-input-fns
  '(("clj" . (lambda ()
               (let ((tap (thing-at-point 'symbol t)))
                 ;; strip namespace
                 (if (string-match-p "/" tap)
                     (cadr (split-string tap "/"))
                   tap))))
    ("el" . (lambda () (thing-at-point 'symbol t)))
    ("js" . (lambda () (thing-at-point 'symbol t)))
    ("php" . (lambda () (thing-at-point 'symbol t))))
  "Controls the input function per file extension.
The result of the input function will be used as input
for every search term defined by the `gg-find-def-extension-search-terms'
variable."
  :type '(alist :key-type string :value-type function)
  :group 'gg-find-def)

;;;###autoload
(defun gg-find-def ()
  "Find definition using git grep.
The input of the git grep command is controlled by the
`gg-find-def-extension-input-fns' and `gg-find-def-extension-search-terms'
variables, which are set per file extension.  Before the search the
current position will be marked."
  (interactive)
  (push-mark)
  (if (locate-dominating-file
       default-directory ".git")
      (let* ((gg-file-ext (file-name-extension (buffer-file-name)))
             (input-fn-assoc (assoc gg-file-ext gg-find-def-extension-input-fns))
             (search-term-assoc (assoc gg-file-ext gg-find-def-extension-search-terms))
             (check (when (not (and input-fn-assoc search-term-assoc))
                      (user-error (concat "Missing customization for file extension: " gg-file-ext))))
             (gg-search (funcall (cdr input-fn-assoc)))
             (search-terms (cdr search-term-assoc))
             (gg-cmd-base "git --no-pager grep --full-name -n --no-color --untracked")
             (gg-cmd (concat gg-cmd-base
                             " "
                             (mapconcat (lambda (x)
                                          (concat "-e '"
                                                  (format x gg-search)
                                                  "'"))
                                        search-terms " ")
                             " -- '*." gg-file-ext "'"))
             (git-dir (expand-file-name
                       (locate-dominating-file
                        default-directory ".git")))
             (default-directory git-dir)
             (gg-res (split-string (shell-command-to-string gg-cmd) "\n" t))
             (full-paths (mapcar (lambda (x) (concat git-dir x)) gg-res)))
        (if (> (length full-paths) 0)
            (let* ((res (if (= 1 (length full-paths))
                            (nth 0 full-paths)
                          (completing-read "Select: " full-paths)))
                   (split-res (split-string res ":"))
                   (file (nth 0 split-res))
                   (linum (nth 1 split-res)))
              (find-file file)
              (goto-char (point-min))
              (forward-line (- (string-to-number linum) 1))
              (recenter-top-bottom))
          (message "No definition found")))
    (message "Not in a git repository")))

(provide 'gg-find-def)

;;; gg-find-def.el ends here
