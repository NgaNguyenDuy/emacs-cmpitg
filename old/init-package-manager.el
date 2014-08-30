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

;;
;; ELPA
;;

(require 'package)

(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
;; (add-to-list 'package-archives
;;              '("SC" . "http://joseito.republika.pl/sunrise-commander/"))

(package-initialize)

;; Fetch the list of available packages
(when (not package-archive-contents)
  (package-refresh-contents))

;;
;; Activate use-package
;;
;; Important note: This must happen before el-get is initialized
;;

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;;
;; el-get - yet another sophisticated package manager
;;
;; https://github.com/dimitri/el-get

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  ;; Install or update
  (cond
   ((fboundp 'el-get-self-update)
    (el-get-self-update))

   (t
    (url-retrieve
     "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
     (lambda (s)
       (goto-char (point-max))
       (eval-print-last-sexp))))))

(add-to-list 'el-get-recipe-path (~get-local-config-dir "el-get-user/recipes"))
;; (el-get 'sync)
(el-get nil)                            ; Call concurrently

;;
;; Add all el-get packages to load-path
;;

(dolist (path (directory-files *el-get-package-dir*))
  (when (file-directory-p path)
    (add-to-list 'load-path path)))

;;
;; Add all local packages to load-path
;;

(let ((local-package-dir (~get-local-config-dir "local-packages/")))
  (dolist (dirname (directory-files local-package-dir))
    (add-to-list 'load-path
                 (concat local-package-dir dirname))))