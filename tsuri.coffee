###
The MIT License (MIT)
Copyright © 2014 Randy Carnahan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.</p>

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

VERSION: 1.1.1
###

class Tsuri
  constructor: (parent, data) ->
    @parent   = parent or null
    @data     = data or {}
    @children = []

    @parent.children.push(this) if @parent

    this.setId()
    this.setDepth()

  generateId: (separator = '-') ->
    return '0' unless @parent

    pid = @parent.id
    idx = @parent.children.indexOf this

    [pid, idx].join separator

  setId: () ->
    @id = this.generateId()

    return this

  setDepth: () ->
    @depth = if @parent then @parent.depth + 1 else 0

    return this

  find: (finder) ->
    return null unless typeof finder is 'function'

    match = null

    this.traverseDown (node) ->
      if finder.call this, node
        match = node

        return false

    return match

  isLeaf: () -> if this.hasChildren() then false else true

  isRoot: () -> if @parent then false else true

  path: (path, separator = '/') ->
    path    = path.substring(1) if path[0] is separator
    indexes = path.split separator
    context = this

    for index in indexes
      index = parseInt index, 10

      if context?.children?.length > index
        context = context.children[index]
      else
        context = null

    return context

  remove: () -> this._removeChild this

  root: () ->
    return this if this.isRoot()

    node = this.parent

    node = node.parent while node.parent

    return node

  siblings: () ->
    return [] if this.isRoot()

    (child for child in @parent.children when child.id isnt @id)

  size: () -> this.toArray().length

  ##################
  # Parent Methods #
  ##################

  hasParent: () -> if @parent then true else false

  removeParent: () ->
    @parent.removeChild(this) if this.hasParent()

    return this

  # This sets the parent of this node to a new
  # parent, creating a new Tsuri node if necessary.
  setParent: (data) ->
    data = new Tsuri(null, data) unless data instanceof Tsuri

    data.appendChild this

    return this

  # This inserts another Tsuri node as a parent
  # of the current node, and assigning the new
  # parent node as a child of the old parent
  # node.
  insertParent: (node) ->
    parent = @parent
    node   = new Tsuri(null, node) unless node instanceof Tsuri

    parent.appendChild(node, false) if parent

    node.appendChild(this)

    node.root().updateChildren()

    return this

  ####################
  # Children Methods #
  ####################

  appendChild: (node, doUpdate = true) ->
    if node instanceof Tsuri
      this._appendChild node, doUpdate
    else
      new Tsuri(this, node)

    return this

  removeChild: (arg) ->
    if typeof arg is 'number' and @children[arg]
      return @children.splice(arg, 1).shift()

    return this._removeChild arg if arg instanceof Tsuri

    throw new Error("Invalid argument: #{arg}")

  hasChildren: () -> @children.length > 0

  updateChildren: () ->
    this.traverseDown (node) ->
      node.setId()
      node.setDepth()

    return this

  #####################
  # Traversal Methods #
  #####################

  breadthEach: (iterator) ->
    this._traverse this, iterator, this._breadthEach

    return

  each: (iterator) -> this.traverseDown iterator

  postOrderEach: (iterator) ->
    this._traverse this, iterator, this._postOrderEach

    return

  traverseDown: (iterator) ->
    this._traverse this, iterator, this._traverseDown

    return

  traverseUp: (iterator) ->
    this._traverse this, iterator, this._traverseUp

    return

  ######################
  # Conversion Methods #
  ######################

  toArray: () ->
    nodes = []

    this.traverseDown (node) -> nodes.push node

    return nodes

  # This create a string from the tree structure.
  # If the `displayAttr` is set, and is a key on
  # the data of the node, then that will be
  # displayed as the 'name' of the node, otherwise,
  # the generated ID will be used instead.
  toString: (displayAttr = null) ->
    this._toStringArray(this, displayAttr).join('\n')

  toJSON: (childrenAttr = 'children', dataHandler) ->
    unless typeof dataHandler is 'function'
      dataHandler = this._defaultDataHandler

    walkDown = (node, parent) ->
      data = dataHandler node

      parent[childrenAttr].push data if parent

      if node.hasChildren()
        data[childrenAttr] = []

        walkDown child, data for child in node.children

      return data

    walkDown this

  ###################
  # Private Methods #
  ###################
  _defaultDataHandler: (node) -> node.data

  _traverse: (context, iterator, callback) ->
    visited = []

    callIterator = (node) ->
      id       = node.id
      returned = null

      unless visited.indexOf(id) > -1
        visited.push id
        return false if iterator.call(node, node) is false

    callback context, callIterator

    return

  _traverseDown: (context, iterator) ->
    doContinue = true

    walkDown = (node) ->
      return unless doContinue

      if iterator(node) is false
        doContinue = false
      else
        for child in node.children
          walkDown child

      return

    walkDown context

    return

  _traverseUp: (context, iterator) ->
    while context
      return if iterator(context) is false

      for child in context.children
        return if iterator(child) is false

      context = context.parent

    return

  _breadthEach: (context, iterator) ->
    queue = [context]

    until queue.length is 0
      node = queue.shift()

      return if iterator.call(node, node) is false

      queue.push child for child in node.children

    return

  _postOrderEach: (context, iterator) ->
    nodes = [{node: context, visited: false}]

    while nodes.length > 0
      peek = nodes[0]

      if peek.node.children.length > 0 and not peek.visited
        peek.visited = true
        children     = []

        for child in peek.node.children
          children.push({node: child, visited: false})

        nodes = children.concat nodes
      else
        node = nodes.shift().node

        return if iterator(node) is false

    return

  _appendChild: (node, doUpdate = true) ->
    node.removeParent()
    @children.push node

    node.parent = this

    this.updateChildren() if doUpdate

    return node

  _removeChild: (node) ->
    parent = node.parent
    value  = null

    for child, idx in parent.children
      value = parent.children.splice(idx, 1).shift() if child is node

    return value

  _toStringArray: (node, displayAttr) ->
    lines  = []
    indent = this._toStringIndent node.depth

    name = if displayAttr and node.data[displayAttr]
      "#{node.data[displayAttr]} (#{node.id})"
    else
      node.id

    lines.push "#{indent}#{name}"

    for child in node.children
      lines = lines.concat this._toStringArray child, displayAttr

    return lines

  _toStringIndent: (num, arrow = '|--> ') ->
    return '' if num <= 0

    indent = '  '
    extra  = ' '
    len    = arrow.length ? 1

    extra += ' '    while len -= 1
    indent += extra while num -= 1

    return "#{indent}#{arrow}"


#######################
# Tsuri Class Methods #
#######################

Tsuri.nodeData = (node, childrenAttr = 'children') ->
  data = {}

  for attr, value of node
    data[attr] = value unless attr is childrenAttr

  return data


Tsuri.parse = (object, childrenAttr = 'children') ->
  root = null

  walkDown = (node, parent) ->
    data = Tsuri.nodeData node, childrenAttr

    if parent
      newNode = new Tsuri parent, data
    else
      newNode = new Tsuri null, data
      root    = newNode

    if node[childrenAttr]
      walkDown child, newNode for child in node[childrenAttr]

  walkDown object

  return root


if typeof module isnt 'undefined' and module.exports
  module.exports = Tsuri
else
  this.Tsuri = Tsuri
