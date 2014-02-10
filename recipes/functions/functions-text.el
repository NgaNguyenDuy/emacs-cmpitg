;;
;; Copyright (C) 2014 Duong Nguyen ([@cmpitg](https://github.com/cmpitg/))
;;
;; This project is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option)
;; any later version.
;;
;; This project is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program.  If not, see <http://www.gnu.org/licenses/>.
;;

(defun ~surround (begin-string end-string)
  "Surround current selection with `begin-string` at the
beginning and `end-string` at the end.  If selection is not
active, insert `begin-string` and `end-string` and place the
cursor in-between them."
  (interactive "sStart string: \nsEnd string: ")
  (cond 
   ((is-selecting?)
    (save-excursion
      (let ((start-point (selection-start))
            (end-point   (selection-end)))
        (goto-point start-point)
        (insert begin-string)
        (goto-point end-point)
        (forward-char (length begin-string))
        (insert end-string))))

   (t
    (insert (concat begin-string end-string))
    (backward-char (length end-string)))))

(defun ~markdown-italicize ()
  "Italicize selection or adding italic format."
  (interactive)
  (~surround "*" "*"))

(defun ~markdown-embolden ()
  "Embolden selection or adding bold format."
  (interactive)
  (~surround "**" "**"))

(defun ~markdown-rawify ()
  "Rawify selection or adding raw format."
  (interactive)
  (~surround "`" "`"))

(defun ~move-to-beginning-of-line ()
  "Move point back to indentation of beginning of line.

Move point to the first non-whitespace character on this line.
If point is already there, move to the beginning of the line."
  (interactive)

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line nil))))

(defun ~duplicate-line ()
  "Duplicate current line."
  (interactive)
  (beginning-of-line)
  (kill-line)
  (yank)
  (newline)
  (yank)
  (beginning-of-line)
  (previous-line))

(defun ~open-line (arg)
  "Open line and move to the next line."
  (interactive "p")
  (end-of-line)
  (delete-horizontal-space)
  (open-line arg)
  (next-line 1)
  (indent-according-to-mode))

(defun ~open-line-before (arg)
  "Open line and move to the previous line."
  (interactive "p")
  (beginning-of-line)
  (open-line arg)
  (indent-according-to-mode))

(defun ~toggle-letter-case ()
  "Toggle the letter case of current word or text selection.
Toggles from 3 cases: UPPER CASE, lower case, Title Case, in that
cyclic order."
  (interactive)
  (let (pos1 pos2 (deactivate-mark nil) (case-fold-search nil))
    (if (and transient-mark-mode mark-active)
      (setq pos1 (region-beginning)
            pos2 (region-end))
      (setq pos1 (car (bounds-of-thing-at-point 'word))
            pos2 (cdr (bounds-of-thing-at-point 'word))))

    (unless (eq last-command this-command)
      (save-excursion
        (goto-char pos1)
        (cond
         ((looking-at "[[:lower:]][[:lower:]]")
          (put this-command 'state "all lower"))
         ((looking-at "[[:upper:]][[:upper:]]")
          (put this-command 'state "all caps"))
         ((looking-at "[[:upper:]][[:lower:]]")
          (put this-command 'state "init caps"))
         (t (put this-command 'state "all lower"))
         )))
    (cond
     ((string= "all lower" (get this-command 'state))
      (upcase-initials-region pos1 pos2)
      (put this-command 'state "init caps"))
     ((string= "init caps" (get this-command 'state))
      (upcase-region pos1 pos2)
      (put this-command 'state "all caps"))
     ((string= "all caps" (get this-command 'state))
      (downcase-region pos1 pos2)
      (put this-command 'state "all lower")))))

(defun ~fix-hard-wrapped-region (begin end)
  "Fix hard-wrapped paragraphs."
  (interactive "r")
  (shell-command-on-region begin end "fmt -w 2500" nil t))

(defun ~mark-word ()
  "Put point at beginning of current word, set mark at end."
  (interactive)
  (let* ((opoint (point))
         (word (current-word))
         (word-length (length word)))
    (if (save-excursion
          ;; Avoid signaling error when moving beyond buffer.
          (if (> (point-min)  (- (point) word-length))
            (beginning-of-buffer)
            (forward-char (- (length word))))
          (search-forward word (+ opoint (length word))
                          'noerror))
      (progn (push-mark (match-end 0) nil t)
             (goto-char (match-beginning 0)))
      (error "No word at point" word))))

(defun ~mark-line ()
  "Mark current line."
  (interactive)
  (beginning-of-line)
  (push-mark (point) t t)
  (end-of-line))

(defun ~insert-me ()
  "Insert my information."
  (interactive)
  (insert *me*))

(defun ~delete-line ()
  "Delete current line."
  (interactive)
  (beginning-of-line)
  (kill-line)
  (kill-line))

(defun ~get-text (start end)
  "Return text from current buffer between start and end point."
  (if (or (< start (point-min))
          (< (point-max) end))
    ""
    (buffer-substring start end)))

(defun ~current-char ()
  "Return the string representing the character at the current
cursor position."
  (~get-text (point) (+ 1 (point))))

(defun ~peek-char ()
  "Peek next character, return the string representing it.."
  (~get-text (+ 1 (point)) (+ 2 (point))))

(defun ~join-with-next-line ()
  "Join next line with the current line.  This is just a
convenient wrapper of `join-line'."
  (interactive)
  (join-line -1))

(defun ~selection-start ()
  "Return the position of the start of the current selection."
  (region-beginning))

(defun ~selection-end ()
  "Return the position of the end of the current selection."
  (region-end))

(defun ~is-selecting? ()
  "Determine if a selection is being held."
  (region-active-p))

(defun ~current-selection ()
  "Return the current selected text."
  (if (is-selecting?)
    (buffer-substring (selection-start)
                      (selection-end))
    ""))

(defun ~get-selection ()
  "Return the current selected text."
  (~current-selection))

(defun ~delete-selected-text ()
  "Delete the selected text, do nothing if none text is selected."
  (if (~is-selecting?)
    (delete-region (selection-start) (selection-end))))

(defun ~replace-selection (&optional text)
  "Replace selection with text."
  (interactive)
  (let ((text (if (stringp text)
                text
                (read-string "Text: "))))
    (call-interactively 'delete-region)
    (insert-string text)))

(defun ~goto-selection-start ()
  "Go to the start of current selection.  If selection is not active,
do nothing."
  (if (~is-selecting?)
    (goto-point (selection-start))))

(defun ~goto-selection-end ()
  "Go to the end of current selection.  If selection is not active,
do nothing."
  (if (~is-selecting?)
    (goto-point (selection-end))))

(defun ~electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match'
then open and indent an empty line between the cursor and the
text.  Move the cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at *electrify-return-match*)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

(defun ~is-selecting? ()
  "Determine if a selection is being held."
  (region-active-p))

(defun ~emacs-lisp-make-alias ()
  "Add \(defalias 'symbol-1 'symbol-2\) to the end of file.
Useful when defining custom Emacs Lisp alias.  I use it when I
want to define a function with `~` prefix to prevent naming
clash, then add \(an\) alias\(es\) without `~`.

By default both `symbol-1` and `symbol-2` are the current
selection."
  (interactive)
  (when (~is-selecting?)
    (save-excursion
      (let* ((new-symbol (read-string "New symbol: " (~current-selection)))
             (old-symbol (read-string "Old symbol: " (~current-selection))))
        (~insert-text-at-the-end (format "(defalias '%s '%s)\n"
                                         new-symbol old-symbol))))))

(defun ~insert-text-at-the-end (&optional text)
  "Insert current selected text at the end of current buffer."
  (interactive)
  (let ((text (cond ((stringp text)
                     text)
                    ((~is-selecting?)
                     (~current-selection))
                    (t
                     (read-string "Text: ")))))
    (call-interactively 'end-of-buffer)
    (insert-string text)))

(defun ~paste-text-at-the-end ()
  "Insert current selected text at the end of current buffer."
  (interactive)
  (call-interactively 'kill-ring-save)
  (end-of-buffer)
  (call-interactively 'yank))

(defun ~mark-word-backward (times)
  "Mark word backward."
  (interactive "p")
  (if (~is-selecting?)
    (kill-region (selection-start) (selection-end))
    (progn (if (and (not (eq last-command this-command))
                    (not (eq last-command 'mark-sexp)))
             (set-mark (point)))
           (backward-word times))))

(defun ~get-unicode-symbol (name)
  "Translate a symbolic name for a Unicode character -- e.g.,
 LEFT-ARROW or GREATER-THAN into an actual Unicode character
 code."
  (decode-char 'ucs (case name
                      (left-arrow 8592)
                      (up-arrow 8593)
                      (right-arrow 8594)
                      (down-arrow 8595)
                      (double-vertical-bar #X2551)
                      (equal #X003d)
                      (not-equal #X2260)
                      (identical #X2261)
                      (not-identical #X2262)
                      (less-than #X003c)
                      (greater-than #X003e)
                      (less-than-or-equal-to #X2264)
                      (greater-than-or-equal-to #X2265)
                      (logical-and #X2227)
                      (logical-or #X2228)
                      (logical-neg #X00AC)
                      ('nil #X2205)
                      (horizontal-ellipsis #X2026)
                      (double-exclamation #X203C)
                      (prime #X2032)
                      (double-prime #X2033)
                      (for-all #X2200)
                      (there-exists #X2203)
                      (element-of #X2208)
                      (square-root #X221A)
                      (squared #X00B2)
                      (cubed #X00B3)
                      (lambda #X03BB)
                      (alpha #X03B1)
                      (beta #X03B2)
                      (gamma #X03B3)
                      (delta #X03B4))))

(defun ~substitute-pattern-with-unicode (pattern symbol)
  "Add a font lock hook to replace the matched part of PATTERN
with the Unicode symbol SYMBOL looked up with UNICODE-SYMBOL."
  (font-lock-add-keywords
      nil `((,pattern
             (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                       ,(~get-unicode-symbol symbol)
                                       'decompose-region)
                       nil))))))

(defun ~substitute-patterns-with-unicode (patterns)
  "Call SUBSTITUTE-PATTERN-WITH-UNICODE repeatedly."
  (mapcar #'(lambda (x)
              (~substitute-pattern-with-unicode (car x)
                                               (cdr x)))
          patterns))

(defalias 'insert-text-at-the-end '~insert-text-at-the-end)
(defalias 'emacs-lisp-make-alias '~emacs-lisp-make-alias)
(defalias 'electrify-return-if-match '~electrify-return-if-match)
(defalias 'goto-selection-end '~goto-selection-end)
(defalias 'goto-selection-start '~goto-selection-start)
(defalias 'replace-selection '~replace-selection)
(defalias 'delete-selected-text '~delete-selected-text)
(defalias 'get-selection '~get-selection)
(defalias 'current-selection '~current-selection)
(defalias 'is-selecting? '~is-selecting?)
(defalias 'selection-end '~selection-end)
(defalias 'selection-start '~selection-start)
(defalias 'join-with-next-line '~join-with-next-line)
(defalias 'peek-char '~peek-char)
(defalias 'current-char '~current-char)
(defalias 'get-text '~get-text)
(defalias 'insert-me '~insert-me)
(defalias '~add-me '~insert-me)
(defalias 'add-me '~insert-me)
(defalias 'mark-line '~mark-line)
(defalias 'mark-word '~mark-word)
(defalias 'fix-hard-wrapped-region '~fix-hard-wrapped-region)
(defalias 'toggle-letter-case '~toggle-letter-case)
(defalias 'open-line-before '~open-line-before)
(defalias 'duplicate-line '~duplicate-line)
(defalias 'move-to-beginning-of-line '~move-to-beginning-of-line)
(defalias 'markdown-italicize '~markdown-italicize)
(defalias 'markdown-embolden '~markdown-embolden)
(defalias 'markdown-rawify '~markdown-rawify)
(defalias 'surround '~surround)
(defalias 'paste-text-at-the-end '~paste-text-at-the-end)
(defalias 'mark-word-backward '~mark-word-backward)
(defalias 'substitute-patterns-with-unicode '~substitute-patterns-with-unicode)
(defalias 'substitute-pattern-with-unicode '~substitute-pattern-with-unicode)
(defalias 'get-unicode-symbol '~get-unicode-symbol)

(defalias '~smart-forward-exp 'forward-word
  "Forward word")

(defalias 'current-point 'point
  "Return current position of the keyboard cursor in the
buffer.")

(defalias '~current-word 'current-word
  "Return the current word as string.")

(defalias 'goto-point 'goto-char
  "Goto `point` in the buffer")