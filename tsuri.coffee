class Tsuri
  constructor: (parent, data, id) ->
    @parent   = parent or null
    @depth    = if @parent then @parent.depth + 1 else 0
    @data     = data or {}
    @id       = id or this._nodeId(@parent)
    @children = []

  find: (finder) ->
    match = null

    finder = this._defaultFinder if typeof finder isnt 'function'

    this.traverseDown (node) ->
      if finder.call this, node
        match = node

        return false

    return match

  isRoot: () -> if @parent then false else true

  length: () -> this.toArray().length

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

    node = this

    node = node.parent while node.parent

    return node

  siblings: () ->
    return [] if this.isRoot()

    return (child for child in @parent.children when child.id isnt @id)

  ####################
  # Children Methods #
  ####################

  appendChild: (data, id) ->
    @children.push new Tsuri(this, data, id)

    return this

  removeChild: (arg) ->
    if typeof arg is 'number' and @children[arg]
      return @children.splice(arg, 1).shift()

    return this._removeChild arg if arg instanceof Tsuri

    throw new Error("Invalid argument: #{arg}")

  hasChildren: () -> @children.length > 0

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

  toString: () -> this._toStringArray(this).join('\n')

  ###################
  # Private Methods #
  ###################

  _defaultFinder: (node, id) -> if node.id is id then true else false

  _traverse: (context, iterator, callback) ->
    visited = []

    callIterator = (node) ->
      id       = node.id
      returned = null

      unless visited.indexOf(id) > -1
        returned = iterator.call node, node
        visited.push id

        return returned if returned is false

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

  _removeChild: (node) ->
    parent = node.parent
    value  = null

    for child, idx in parent.children
      value = parent.children.splice(idx, 1).shift() if child is node

    return value

  _nodeId: (parent, separator = '-') ->
    if parent
      [parent.id, parent.children.length].join separator
    else
      '0'

  _toStringArray: (node) ->
    lines  = []
    indent = this._toStringIndent node.depth

    lines.push "#{indent}#{node.id}"

    for child in node.children
      lines = lines.concat this._toStringArray child

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
      parent.children.push newNode
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
