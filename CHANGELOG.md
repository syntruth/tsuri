# Tsuri Change Log

## 1.0.0 - 2014-10-15

'Forked' Arboreal, which really meant rewriting the entire thing in CoffeeScript.

This was done because Arboreal had some issues I was having to hack around, and it
doesn't look like it was touched or update much lately, so I decided to just rewrite
it in CoffeeScript to make keeping it up to date easier and cleaner. In the process,
I decided to add some new methods to make traversal more complete, much of which was
inspired by the RubyTree gem.

### Added
- `hasChildren()`
- `siblings()`
- `isLeaf()`
- `size()`
- `each()`
- `breadthEach()`
- `postOrderEach()`
- `toJSON()`

### Changed
- `find()` method no longer searches for an ID if no finder method if given.

### Removed
- `length` propery, since `__defineGetter__` is not a standard JavaScript
  construct. There is now the `size()` method to be used instead.