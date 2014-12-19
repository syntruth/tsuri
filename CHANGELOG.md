# Tsuri Change Log

## 1.1.1 - 2014-12-18
- Added `insertParent()` method to insert a node between a child and its original
  parent node, while updating each node's properties (ID and depth) to reflect
  their new positions.
- Added `setParent()` as a wrapper to the parent's `appendChild()` method, but it
  also checks to see if the given argument is a Tsuri instance or not.
- Added `removeParent()` as a wrapper for removing a node from its parent via a
  call to the parent's `removeChild()` method.
- Added `updateChildren()` to traverse the tree starting with the current node and
  updating the ID and Depth of the node's children.
- Added `generateId()`, `setId()`, and `setDepth()` methods to handle setting the
  ID and depth properties outside of the constructor, so they can be called later
  on to update those properties post-instatiation.
  now always generated with a node is added, or moved within the tree.
- Added `hasParent()` that returns a boolean on if the node has a parent or not.

### Changed
- Updated the `toString()` method to take an optional argument, `displayAttr`, that
  if set to a key on the node's `data` property, will insert that key's value into
  the node's string representation, with the node's ID after it within parenthesis.
- Changed `appendChild()` to have a new, optional argument `doUpdate`, which if
  set to true (the default), then the parent node's `updateChildren()` method 
  will be called.
- Changed `appendChild()` so if the `data` argumment is already a Tsuri instance,
  it is handled more directly in a private method, so that it is added to the
  parent's `children` array and has its properties set correctly.

### Removed
- Removed the `id` argument from the constructor and related methods. All IDs are
  now auto-generated.

## 1.1.0 - 2014-10-21

### Changed
- Updated `Tsuri.parse()` for the change to the constructor and `appendChild()`.
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
