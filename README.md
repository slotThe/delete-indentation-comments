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
