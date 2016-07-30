[![License GPL 3][badge-license]](http://www.gnu.org/licenses/gpl-3.0.txt)

## gg-find-def for emacs
Find the definition of a symbol in a git repository using git grep. The search terms describing how to find a possible definition are customizable per file extension.

Currently the customization variables only contain defaults for clojure, elisp, javascript and php files.

<p align="center">
    <img src="https://raw.github.com/mallt/gg-find-def/master/gg-find-def.gif" alt="gg-find-def screencast"/>
</p>

## Installation
Bind the `gg-find-def` function to the keybinding of your choice, f.ex. <kbd>C-c f d</kbd>.

## Customization
The behavior of the `gg-find-def` function can be customized per file extension with 2 variables:

### `gg-find-def-extension-search-terms`
This is an association list that maps file extensions to a list of search terms. A search term is a string that describes how a possible definition can be found. It has to contain a %s string argument that will be replaced by the return value of the input function defined in the `gg-find-def-extension-input-fns` variable. All search terms will be used by the git grep command to locate possible definitions.

The default value of this variable contains only a couple of extensions, f.ex. the association for elisp files is `("el" . ("defun %s" "defmacro %s" "defvar %s" "defcustom %s"))`. This means the `gg-find-def` function will try to find the definition of a symbol by looking for occurences of defun, defmacro, defvar and defcustom.

### `gg-find-def-extension-input-fns`
This is an assocation list that maps file extensions to an input function. The result of the input function will be used as input for every search term specified by the `gg-find-def-extension-search-terms` variable.

The default value of this variable contains only a couple of extensions, f.ex. the association for elisp files is `("el" . (lambda () (thing-at-point 'symbol t)))`. This means the `gg-find-def` function will replace the %s string argument of the search terms by the thing at point.

## Usage
Move the point to a symbol and try to find its definition in the current git repository by pressing the keybinding for the `gg-find-def` function (f.ex. <kbd>C-c f d</kbd>). If more than 1 candidate is found, a list of candidates will be displayed.

Before jumping to the definition the current position will be marked, so jumping back to the position before the find can be done by popping the mark off the local (<kbd>C-u C-SPC</kbd>) or global find ring (<kbd>C-x C-SPC</kbd>).


[badge-license]: https://img.shields.io/badge/license-GPL_3-green.svg
