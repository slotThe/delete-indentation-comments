;;; delete-indentation-comments.el --- A comment-aware `delete-indentation' -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Tony Zorman
;;
;; Author: Tony Zorman <soliditsallgood@mailbox.org>
;; Keywords: convenience
;; Version: 0.1
;; Package-Requires: ((emacs "29.1"))
;; Homepage: https://github.com/slotThe/delete-indentation-comments

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Monkey-patches `delete-indentation' to be aware of comments; i.e., joining
;; adjacent lines of comments deletes the comment from the lines being joined.
;; See [1] for a more thorough explanation.
;;
;; [1]: https://tony-zorman.com/posts/join-lines-comments.html

;;; Code:

;;;###autoload
(defun delete-indentation (&optional arg beg end)
  "Join this line to previous and fix up whitespace at join.
If there is a fill prefix, delete it from the beginning of this line.
With prefix ARG, join the current line to the following line.  When BEG
and END are non-nil, join all lines in the region they define.
Interactively, BEG and END are, respectively, the start and end of the
region if it is active, else nil.  (The region is ignored if prefix ARG
is given.)

When joining lines, smartly delete comment beginnings, such that one
does not have to do this by oneself."
  (interactive
   (progn (barf-if-buffer-read-only)
          (cons current-prefix-arg
                (and (use-region-p)
                     (list (region-beginning) (region-end))))))
  ;; Consistently deactivate mark even when no text is changed.
  (setq deactivate-mark t)
  (if (and beg (not arg))
      ;; Region is active.  Go to END, but only if region spans
      ;; multiple lines.
      (and (goto-char beg)
           (> end (line-end-position))
           (goto-char end))
    ;; Region is inactive.  Set a loop sentinel
    ;; (subtracting 1 in order to compare less than BOB).
    (setq beg (1- (line-beginning-position (and arg 2))))
    (when arg (forward-line)))
  (let* ((comment (string-trim-right comment-start))
         (prefix-start (and (> (length comment-start) 0)
                            (regexp-quote comment)))
         ;; A continuation of a comment. This is important for languages where
         ;; two symbols start the comments, but more may follows (e.g.,
         ;; Haskell, where -- starts a comments, and --- still is one.)
         (prefix-cont (and prefix-start (regexp-quote (substring comment 0 1))))
         (prev-comment?                 ; Comment on previous line?
          (save-excursion
            (forward-line -1)
            (back-to-indentation)
            (search-forward prefix-start (pos-eol) 'no-error))))
    (while (and (> (line-beginning-position) beg)
                (forward-line 0)
                (= (preceding-char) ?\n))
      (delete-char -1)
      (delete-horizontal-space)
      ;; Delete the start of a comment once.
      (when (and prev-comment? prefix-start (looking-at prefix-start))
        (replace-match "" t t)
        ;; Look for continuations.
        (while (and prefix-cont (looking-at prefix-cont))
          (replace-match "" t t)))
      (fixup-whitespace))))

(provide 'delete-indentation-comments)
;;; delete-indentation-comments.el ends here
