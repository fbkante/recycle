;;; recycle.el

;; Author: Koji Mitsuda <fbkante2u atmark gmail.com>
;; Keywords: convenience, repeat
;; Version: 0.9

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; version 0.91 recycle-translate-alistを変更

;;標準の変換用コマンドのために、requireしておく
(require 'subword)

;;コマンドの変換テーブル 指定されたコマンドを実行する。nilは何も実行しない。tは変換前コマンドをそのまま再実行する
(defvar recycle-translate-alist
  '((forward-char             subword-forward        subword-backward)
    (backward-char            subword-backward       subword-forward)
    (self-insert-command      kill-word              subword-kill)
    (delete-char              kill-word              subword-kill)
    (backward-delete-char     backward-kill-word     subword-backward-kill)
    (next-line                end-of-defun           beginning-of-defun)
    (previous-line            beginning-of-defun     end-of-defun)
    (recenter-top-bottom      scroll-up-line         scroll-down-line)))

;;念のため、これらのコマンドは無視する
(defvar recycle-ignore '(kill-this-buffer kill-buffer recycle recycle-2nd repeat))

(defun recycle-internal (index default)
  (let* ((lastcmd last-command)
	 (translate (assq lastcmd recycle-translate-alist))
	 (cmd (nth index translate)))
    (when (null cmd) (setq cmd default))
    (when (eq cmd t) (setq cmd lastcmd))
    (when (memq cmd recycle-ignore) (setq cmd nil))
    (when (commandp cmd)
      (condition-case err
	  (command-execute cmd)
	(error (message "%s" (error-message-string err)))))
    (setq this-command lastcmd)))

;;一つ前のコマンドに対応するコマンドを実行する。
;;登録されたコマンドがなければ、一つ前のコマンドをそのまま実行する。
(defun recycle ()
  (interactive)
  (recycle-internal 1 t))

;;一つ前のコマンドに対応する２番目のコマンドを実行する。
;;登録されたコマンドがなければ、何もしない。
(defun recycle-2nd ()
  (interactive)
  (recycle-internal 2 nil))

(provide 'recycle)
