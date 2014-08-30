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
;; Global variables
;;

(setq _config-dir (file-name-directory (or load-file-name
                                            (buffer-file-name))))

(load-file (concat _config-dir "init-global-vars.el"))
(load-file (concat _config-dir "init-essential-functions.el"))

(~start-emacs-server)

;;
;; Main code
;;

(~load-config-files "load-functions.el")
(~load-config-files "init-package-manager.el")

;; Eval the next sexp if you're running this config set for the first time.
;; TODO: automate this by makeing a script to install
;;   (~load-config-files "init-packages.el")

(~load-config-files "init-essential-packages.el")
(~load-config-files "load-keymaps.el")
(~load-config-files "load-packages.el")
(~load-config-files "load-environment.el")
(~load-config-files "load-menu.el")
(~load-config-files "load-personal-stuff.el")