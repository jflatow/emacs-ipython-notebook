;;; ein-smartrep.el --- smartrep integration

;; Copyright (C) 2012- Takafumi Arakaki

;; Author: Takafumi Arakaki

;; This file is NOT part of GNU Emacs.

;; ein-smartrep.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein-smartrep.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-smartrep.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'smartrep)
(require 'ein-notebook)

(smartrep-define-key
    ein:notebook-mode-map
    "C-c"
  '(("C-t" . ein:notebook-toggle-cell-type)
    ("C-d" . ein:notebook-delete-cell-command)
    ("C-b" . ein:notebook-insert-cell-below-command)
    ("C-n" . ein:notebook-goto-next-cell)
    ("C-p" . ein:notebook-goto-prev-cell)
    ))

(provide 'ein-smartrep)

;;; ein-smartrep.el ends here