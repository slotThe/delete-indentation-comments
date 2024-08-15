# delete-indentation-comments

Monkey-patches `delete-indentation` to be aware of comments;
i.e., joining adjacent lines of comments deletes the comment from the lines being joined.
For example,

``` rust
/// A comment,
/// and a continuation
```

when joined, would result in

``` rust
/// A comment, and a continuation
```

See
[here](https://tony-zorman.com/posts/join-lines-comments.html)
for a more thorough explanation.

## Installation

You can use `package-vc-install`:

``` emacs-lisp
(package-vc-install
 '(delete-indentation-comments . (:url "https://github.com/slotThe/delete-indentation-comments")))
```

Additionally, [vc-use-package](https://github.com/slotThe/vc-use-package) provides use-package integration:

``` emacs-lisp
(use-package delete-indentation-comments
  :vc (:fetcher github :repo slotThe/delete-indentation-comments))
```

Alternatively, if you're on Emacs 30 or newer, a `:vc` keyword is built into use-package:

``` emacs-lisp
(use-package delete-indentation-comments
 :vc (:url "https://github.com/slotThe/delete-indentation-comments"))
```

If you are installing with use-package, make sure to `:defer nil` the package as well.
