# Tsuri Change Log

## Unreleased
- Changed `appendChild()` so if the `data` argumment is already a Tsuri instance,
  then it is added to the `children` property array immediately and has its `parent`
  property set instead of being passed to the constructor.

## 1.1.0 - 2014-10-21

### Changed
- Updated `Tsuri.parse()` fort he change to the constructor and `appendChild()`.
- `appendChild()` no longer directly adds the new child node to the parent, as that
  is now handled in the constructor.
- Changed the constructor to add the intializing node to the `parent` node if it's
  not null.
- `root()` is a _teensy weensy_ bit more optimized, where if the called node isn't
  root, then it starts with that node's parent instead of with that node.
- Removed the extraneous return statement from `siblings()` in the coffee version.

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
